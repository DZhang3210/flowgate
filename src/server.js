const app = require('./app');
const config = require('./config');
const { runMigrations } = require('./db/migrations');
const redis = require('./cache/client');

async function start() {
  try {
    // Connect Redis
    await redis.connect();

    // Run DB migrations
    await runMigrations();

    // Start HTTP server
    app.listen(config.port, () => {
      console.log(JSON.stringify({
        level: 'info',
        msg:   `FlowGate API started`,
        port:  config.port,
        env:   config.nodeEnv,
      }));
    });
  } catch (err) {
    console.error(JSON.stringify({ level: 'error', msg: 'Startup failed', error: err.message }));
    process.exit(1);
  }
}

start();
