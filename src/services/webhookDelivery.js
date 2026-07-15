const axios = require('axios');

/**
 * Delivers a webhook event to the tenant's registered URL.
 * Called by the worker for each message consumed from the queue.
 *
 * On failure, throws — the queue driver handles retry logic:
 *   - Redis driver: message is lost after max retries (acceptable for local dev)
 *   - SQS driver:   message returns to queue after visibility timeout, up to
 *                   maxReceiveCount before landing in the DLQ
 */
async function deliverWebhook(message) {
  const { tenantId, webhookUrl, thresholdPct, current, limit, triggeredAt } = message;

  const payload = {
    event:        'rate_limit_threshold',
    tenantId,
    thresholdPct,
    usage:        { current, limit },
    triggeredAt,
  };

  const start = Date.now();
  try {
    await axios.post(webhookUrl, payload, {
      timeout: 10000,
      headers: { 'Content-Type': 'application/json', 'User-Agent': 'FlowGate/1.0' },
    });

    const latencyMs = Date.now() - start;
    console.log(JSON.stringify({
      level:      'info',
      msg:        'Webhook delivered',
      _aws: {
        Timestamp: Date.now(),
        CloudWatchMetrics: [{
          Namespace: 'flowgate',
          Dimensions: [[]],
          Metrics: [{ Name: 'WebhookDeliverySuccess', Unit: 'Count' }],
        }],
      },
      WebhookDeliverySuccess: 1,
      tenantId,
      webhookUrl,
      latencyMs,
    }));
  } catch (err) {
    const latencyMs = Date.now() - start;
    console.error(JSON.stringify({
      level:      'error',
      msg:        'Webhook delivery failed',
      _aws: {
        Timestamp: Date.now(),
        CloudWatchMetrics: [{
          Namespace: 'flowgate',
          Dimensions: [[]],
          Metrics: [{ Name: 'WebhookDeliveryFailure', Unit: 'Count' }],
        }],
      },
      WebhookDeliveryFailure: 1,
      tenantId,
      webhookUrl,
      latencyMs,
      error: err.message,
    }));
    throw err; // re-throw so the queue driver can handle retry
  }
}

module.exports = { deliverWebhook };
