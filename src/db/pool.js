const { Pool } = require('pg');
const config = require('../config');

const pool = new Pool({
  host: config.db.host,
  port: config.db.port,
  database: config.db.database,
  user: config.db.user,
  password: config.db.password,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
  ssl: { rejectUnauthorized: false },
});

pool.on('error', (err) => {
  console.error(JSON.stringify({ level: 'error', msg: 'Postgres pool error', error: err.message }));
});

module.exports = pool;
