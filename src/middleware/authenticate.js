const crypto = require('crypto');
const pool = require('../db/pool');

/**
 * Extracts the Bearer token from Authorization header,
 * looks up the api_key + tenant, and attaches to req:
 *   req.apiKey  = { id, tenantId, keyHash, revoked }
 *   req.tenant  = { id, name, plan, webhookUrl }
 */
async function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const rawKey = authHeader.slice(7).trim();
  const keyHash = crypto.createHash('sha256').update(rawKey).digest('hex');

  try {
    const result = await pool.query(
      `SELECT
         k.id          AS key_id,
         k.tenant_id,
         k.revoked,
         t.id          AS tenant_id,
         t.name        AS tenant_name,
         t.plan,
         t.webhook_url
       FROM api_keys k
       JOIN tenants t ON t.id = k.tenant_id
       WHERE k.key_hash = $1`,
      [keyHash]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    const row = result.rows[0];

    if (row.revoked) {
      return res.status(401).json({ error: 'API key has been revoked' });
    }

    req.apiKey = { id: row.key_id, keyHash };
    req.tenant = {
      id: row.tenant_id,
      name: row.tenant_name,
      plan: row.plan,
      webhookUrl: row.webhook_url,
    };

    next();
  } catch (err) {
    console.error(JSON.stringify({ level: 'error', msg: 'Auth middleware error', error: err.message }));
    res.status(500).json({ error: 'Internal server error' });
  }
}

module.exports = { authenticate };
