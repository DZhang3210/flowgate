const { Router } = require('express');
const pool = require('../db/pool');
const { authenticate } = require('../middleware/authenticate');
const { rateLimit } = require('../middleware/rateLimit');

const router = Router();

// All /api routes require a valid API key + rate limit check
router.use(authenticate, rateLimit);

/**
 * GET /api/data
 *
 * The core rate-limited endpoint. Returns a mock payload and records
 * the request in usage_logs (which drives GET /tenants/:id/usage).
 */
router.get('/data', async (req, res) => {
  const start = Date.now();

  const payload = {
    requestId: require('crypto').randomUUID(),
    tenantId:  req.tenant.id,
    data: [
      { id: 1, value: 'alpha',   score: 0.91 },
      { id: 2, value: 'beta',    score: 0.87 },
      { id: 3, value: 'gamma',   score: 0.74 },
      { id: 4, value: 'delta',   score: 0.65 },
      { id: 5, value: 'epsilon', score: 0.58 },
    ],
    rateLimit: {
      limit:     req.rateLimitInfo.limit,
      remaining: req.rateLimitInfo.remaining,
      resetAt:   new Date(req.rateLimitInfo.windowEndsAt).toISOString(),
    },
    timestamp: new Date().toISOString(),
  };

  const latencyMs = Date.now() - start;

  // Log structured request for CloudWatch Logs Insights queries
  console.log(JSON.stringify({
    level:      'info',
    msg:        'API request',
    tenantId:   req.tenant.id,
    apiKeyId:   req.apiKey.id,
    endpoint:   '/api/data',
    statusCode: 200,
    latencyMs,
  }));

  // Record in usage_logs (fire-and-forget to not block response)
  pool.query(
    `INSERT INTO usage_logs (api_key_id, tenant_id, endpoint, status_code, latency_ms)
     VALUES ($1, $2, $3, $4, $5)`,
    [req.apiKey.id, req.tenant.id, '/api/data', 200, latencyMs]
  ).catch((err) => {
    console.error(JSON.stringify({ level: 'error', msg: 'Usage log insert failed', error: err.message }));
  });

  res.json(payload);
});

module.exports = router;
