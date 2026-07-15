const redis = require('../cache/client');
const config = require('../config');
const { publishWebhookEvent } = require('../services/webhookPublisher');

/**
 * Sliding-window rate limiter using Redis INCR + EXPIRE.
 * Window: 1 minute, keyed by api_key hash.
 *
 * Attaches to req:
 *   req.rateLimitInfo = { limit, current, remaining, windowEndsAt }
 *
 * On Redis failure: FAIL OPEN (allow the request).
 * This is a deliberate decision — document it in Phase 8 chaos engineering.
 */
async function rateLimit(req, res, next) {
  const { apiKey, tenant } = req;
  const limit = config.rateLimits[tenant.plan] || config.rateLimits.free;

  // 1-minute fixed window: floor(epoch_seconds / 60)
  const window = Math.floor(Date.now() / 1000 / 60);
  const redisKey = `rl:${apiKey.keyHash}:${window}`;

  let current;
  try {
    current = await redis.incr(redisKey);
    // Set TTL on first increment so the key expires after the window
    if (current === 1) {
      await redis.expire(redisKey, 70); // 70s: window + small buffer
    }
  } catch (err) {
    // Redis unavailable — fail open, log the decision
    console.error(JSON.stringify({
      level: 'warn',
      msg: 'Redis unavailable — rate limiting skipped (fail open)',
      tenantId: tenant.id,
      error: err.message,
    }));
    return next();
  }

  const remaining = Math.max(0, limit - current);
  const windowEndsAt = (window + 1) * 60 * 1000; // epoch ms

  req.rateLimitInfo = { limit, current, remaining, windowEndsAt };

  // Set standard rate-limit headers
  res.set({
    'X-RateLimit-Limit':     String(limit),
    'X-RateLimit-Remaining': String(remaining),
    'X-RateLimit-Reset':     String(Math.floor(windowEndsAt / 1000)),
  });

  if (current > limit) {
    // Emit custom CloudWatch metric (stdout JSON picked up by CloudWatch Logs agent)
    console.log(JSON.stringify({
      level: 'info',
      msg: 'Rate limit exceeded',
      _aws: {
        Timestamp: Date.now(),
        CloudWatchMetrics: [{
          Namespace: 'flowgate',
          Dimensions: [['TenantId']],
          Metrics: [{ Name: 'RateLimitHits', Unit: 'Count' }],
        }],
      },
      TenantId: tenant.id,
      RateLimitHits: 1,
    }));

    return res.status(429).json({
      error: 'Rate limit exceeded',
      limit,
      remaining: 0,
      resetAt: new Date(windowEndsAt).toISOString(),
    });
  }

  // Publish webhook event at 80% and 100% thresholds (fire-and-forget)
  const usagePct = (current / limit) * 100;
  if (usagePct >= 100 && current - 1 < limit) {
    publishWebhookEvent(tenant, 100, current, limit).catch(() => {});
  } else if (usagePct >= 80 && current - 1 < limit * 0.8) {
    publishWebhookEvent(tenant, 80, current, limit).catch(() => {});
  }

  next();
}

module.exports = { rateLimit };
