const pool = require('./pool');

const schema = `
  CREATE TABLE IF NOT EXISTS tenants (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    email       VARCHAR(255) UNIQUE NOT NULL,
    plan        VARCHAR(50)  NOT NULL DEFAULT 'free',
    webhook_url TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS api_keys (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   UUID         NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    key_prefix  VARCHAR(10)  NOT NULL,
    key_hash    VARCHAR(64)  NOT NULL UNIQUE,
    label       VARCHAR(255),
    revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
  );

  CREATE INDEX IF NOT EXISTS idx_api_keys_key_hash   ON api_keys(key_hash);
  CREATE INDEX IF NOT EXISTS idx_api_keys_tenant_id  ON api_keys(tenant_id);

  CREATE TABLE IF NOT EXISTS usage_logs (
    id           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    api_key_id   UUID    NOT NULL REFERENCES api_keys(id),
    tenant_id    UUID    NOT NULL,
    endpoint     VARCHAR(255) NOT NULL,
    status_code  INTEGER NOT NULL,
    latency_ms   INTEGER,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  CREATE INDEX IF NOT EXISTS idx_usage_logs_tenant_id    ON usage_logs(tenant_id);
  CREATE INDEX IF NOT EXISTS idx_usage_logs_requested_at ON usage_logs(requested_at);
`;

async function runMigrations() {
  const client = await pool.connect();
  try {
    await client.query(schema);
    console.log(JSON.stringify({ level: 'info', msg: 'Database migrations complete' }));
  } finally {
    client.release();
  }
}

module.exports = { runMigrations };
