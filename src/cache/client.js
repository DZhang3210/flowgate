const Redis = require('ioredis');
const config = require('../config');

const client = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
  lazyConnect: true,
  retryStrategy: (times) => Math.min(times * 100, 3000),
});

client.on('connect', () => {
  console.log(JSON.stringify({ level: 'info', msg: 'Redis connected' }));
});

client.on('error', (err) => {
  console.error(JSON.stringify({ level: 'error', msg: 'Redis error', error: err.message }));
});

module.exports = client;
