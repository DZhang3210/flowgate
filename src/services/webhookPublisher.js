const queue = require('../queue');

/**
 * Publishes a webhook event to the queue when a tenant crosses
 * a rate limit threshold (80% or 100%).
 *
 * The worker process (src/worker.js) consumes these messages and
 * delivers the HTTP POST to the tenant's registered webhook URL.
 */
async function publishWebhookEvent(tenant, thresholdPct, current, limit) {
  if (!tenant.webhookUrl) return;

  const message = {
    tenantId:     tenant.id,
    tenantName:   tenant.name,
    webhookUrl:   tenant.webhookUrl,
    thresholdPct,
    current,
    limit,
    triggeredAt:  new Date().toISOString(),
  };

  await queue.publish(message);

  console.log(JSON.stringify({
    level: 'info',
    msg:   'Webhook event published',
    tenantId:     tenant.id,
    thresholdPct,
  }));
}

module.exports = { publishWebhookEvent };
