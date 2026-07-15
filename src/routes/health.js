const { Router } = require('express');
const pool = require('../db/pool');
const redis = require('../cache/client');

const router = Router();

/**
 * GET /health
 * Used by the ALB health check. Returns 200 only when both Postgres
 * and Redis are reachable. Returns 503 otherwise so the ALB can
 * remove unhealthy tasks from the target group.
 */
router.get('/health', async (req, res) => {
  const checks = { postgres: false, redis: false };

  try {
    await pool.query('SELECT 1');
    checks.postgres = true;
  } catch (_) {}

  try {
    await redis.ping();
    checks.redis = true;
  } catch (_) {}

  const healthy = checks.postgres && checks.redis;
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'ok' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
