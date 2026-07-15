const config = require('./config');
const queue = require('./queue');
const { deliverWebhook } = require('./services/webhookDelivery');

async function start() {
  // Redis connection needed for the local queue driver
  if (config.queue.driver === 'redis') {
    const redis = require('./cache/client');
    await redis.connect();
  }

  console.log(JSON.stringify({
    level:  'info',
    msg:    'FlowGate worker started',
    driver: config.queue.driver,
    env:    config.nodeEnv,
  }));

  // Blocking consume loop — runs forever
  await queue.consume(deliverWebhook);
}

start().catch((err) => {
  console.error(JSON.stringify({ level: 'error', msg: 'Worker startup failed', error: err.message }));
  process.exit(1);
});
