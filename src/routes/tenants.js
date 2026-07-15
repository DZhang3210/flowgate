const { Router } = require('express');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const pool = require('../db/pool');

const router = Router();

// ─── POST /tenants ───────────────────────────────────────────────────────────

router.post('/', async (req, res) => {
  const { name, email, plan = 'free', webhookUrl } = req.body;

  if (!name || !email) {
    return res.status(400).json({ error: 'name and email are required' });
  }

  if (!['free', 'pro', 'enterprise'].includes(plan)) {
    return res.status(400).json({ error: 'plan must be free, pro, or enterprise' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO tenants (name, email, plan, webhook_url)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, plan, webhook_url, created_at`,
      [name, email, plan, webhookUrl || null]
    );

    console.log(JSON.stringify({ level: 'info', msg: 'Tenant created', tenantId: result.rows[0].id }));
    res.status(201).json(result.rows[0]);
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Email already registered' });
    }
    console.error(JSON.stringify({ level: 'error', msg: 'Create tenant error', error: err.message }));
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── GET /tenants/:id ────────────────────────────────────────────────────────

router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, email, plan, webhook_url, created_at FROM tenants WHERE id = $1',
      [req.params.id]
    );

    if (result.rows.length === 0) return res.status(404).json({ error: 'Tenant not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── PATCH /tenants/:id ──────────────────────────────────────────────────────

router.patch('/:id', async (req, res) => {
  const { webhookUrl } = req.body;

  try {
    const result = await pool.query(
      `UPDATE tenants SET webhook_url = $1 WHERE id = $2
       RETURNING id, name, email, plan, webhook_url, created_at`,
      [webhookUrl || null, req.params.id]
    );

    if (result.rows.length === 0) return res.status(404).json({ error: 'Tenant not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── POST /tenants/:id/keys ──────────────────────────────────────────────────

router.post('/:id/keys', async (req, res) => {
  const { label } = req.body;

  // Verify tenant exists
  const tenantResult = await pool.query('SELECT id FROM tenants WHERE id = $1', [req.params.id]);
  if (tenantResult.rows.length === 0) {
    return res.status(404).json({ error: 'Tenant not found' });
  }

  // Generate a random API key: "fg_" + 32 random hex chars
  const rawKey = 'fg_' + crypto.randomBytes(16).toString('hex');
  const keyHash = crypto.createHash('sha256').update(rawKey).digest('hex');
  const keyPrefix = rawKey.slice(0, 10); // display prefix only

  try {
    const result = await pool.query(
      `INSERT INTO api_keys (tenant_id, key_prefix, key_hash, label)
       VALUES ($1, $2, $3, $4)
       RETURNING id, tenant_id, key_prefix, label, created_at`,
      [req.params.id, keyPrefix, keyHash, label || null]
    );

    console.log(JSON.stringify({ level: 'info', msg: 'API key created', tenantId: req.params.id, keyId: result.rows[0].id }));

    // Return the raw key ONCE — it cannot be retrieved again
    res.status(201).json({
      ...result.rows[0],
      key: rawKey,  // only returned at creation time
    });
  } catch (err) {
    console.error(JSON.stringify({ level: 'error', msg: 'Create key error', error: err.message }));
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── GET /tenants/:id/keys ───────────────────────────────────────────────────

router.get('/:id/keys', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, key_prefix, label, revoked, created_at
       FROM api_keys WHERE tenant_id = $1 ORDER BY created_at DESC`,
      [req.params.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── DELETE /tenants/:id/keys/:keyId ────────────────────────────────────────

router.delete('/:id/keys/:keyId', async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE api_keys SET revoked = TRUE
       WHERE id = $1 AND tenant_id = $2
       RETURNING id`,
      [req.params.keyId, req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Key not found' });
    }

    console.log(JSON.stringify({ level: 'info', msg: 'API key revoked', keyId: req.params.keyId }));
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ─── GET /tenants/:id/usage ──────────────────────────────────────────────────

router.get('/:id/usage', async (req, res) => {
  try {
    const [today, month, limitHits] = await Promise.all([
      pool.query(
        `SELECT COUNT(*) AS count FROM usage_logs
         WHERE tenant_id = $1 AND requested_at >= CURRENT_DATE`,
        [req.params.id]
      ),
      pool.query(
        `SELECT COUNT(*) AS count FROM usage_logs
         WHERE tenant_id = $1 AND requested_at >= DATE_TRUNC('month', NOW())`,
        [req.params.id]
      ),
      pool.query(
        `SELECT COUNT(*) AS count FROM usage_logs
         WHERE tenant_id = $1 AND status_code = 429
           AND requested_at >= DATE_TRUNC('month', NOW())`,
        [req.params.id]
      ),
    ]);

    res.json({
      tenantId:        req.params.id,
      requestsToday:   parseInt(today.rows[0].count, 10),
      requestsThisMonth: parseInt(month.rows[0].count, 10),
      rateLimitHitsThisMonth: parseInt(limitHits.rows[0].count, 10),
    });
  } catch (err) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
