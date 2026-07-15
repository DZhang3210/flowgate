/**
 * Queue abstraction.
 * - driver=redis : uses a Redis LIST (LPUSH to publish, BRPOP to consume)
 * - driver=sqs   : uses AWS SQS (swap in for production)
 *
 * Both drivers expose the same interface:
 *   publish(message: object): Promise<void>
 *   consume(handler: (message: object) => Promise<void>): Promise<void>  [blocking loop]
 */

const config = require('../config');

// ─── Redis driver ───────────────────────────────────────────────────────────

function createRedisQueue() {
  // Use separate connections: one for publishing, one for blocking reads
  const Redis = require('ioredis');

  const publisher = new Redis({
    host: config.redis.host,
    port: config.redis.port,
    password: config.redis.password,
  });

  const consumer = new Redis({
    host: config.redis.host,
    port: config.redis.port,
    password: config.redis.password,
  });

  const key = `queue:${config.queue.name}`;

  return {
    async publish(message) {
      await publisher.lpush(key, JSON.stringify(message));
    },

    async consume(handler) {
      console.log(JSON.stringify({ level: 'info', msg: `Worker polling Redis queue: ${key}` }));
      while (true) {
        try {
          // BRPOP blocks up to 5s, returns [key, value] or null on timeout
          const result = await consumer.brpop(key, 5);
          if (!result) continue;

          const message = JSON.parse(result[1]);
          await handler(message);
        } catch (err) {
          console.error(JSON.stringify({ level: 'error', msg: 'Queue consume error', error: err.message }));
          await new Promise((r) => setTimeout(r, 1000)); // back off on error
        }
      }
    },
  };
}

// ─── SQS driver ─────────────────────────────────────────────────────────────

function createSqsQueue() {
  const { SQSClient, SendMessageCommand, ReceiveMessageCommand, DeleteMessageCommand } =
    require('@aws-sdk/client-sqs');

  const sqs = new SQSClient({ region: config.aws.region });
  const queueUrl = config.queue.sqsQueueUrl;

  return {
    async publish(message) {
      await sqs.send(new SendMessageCommand({
        QueueUrl: queueUrl,
        MessageBody: JSON.stringify(message),
      }));
    },

    async consume(handler) {
      console.log(JSON.stringify({ level: 'info', msg: `Worker polling SQS queue: ${queueUrl}` }));
      while (true) {
        try {
          const response = await sqs.send(new ReceiveMessageCommand({
            QueueUrl: queueUrl,
            MaxNumberOfMessages: 10,
            WaitTimeSeconds: 20,  // long polling
          }));

          const messages = response.Messages || [];
          await Promise.all(messages.map(async (msg) => {
            try {
              await handler(JSON.parse(msg.Body));
              await sqs.send(new DeleteMessageCommand({
                QueueUrl: queueUrl,
                ReceiptHandle: msg.ReceiptHandle,
              }));
            } catch (err) {
              // Don't delete — SQS will redeliver after visibility timeout
              console.error(JSON.stringify({ level: 'error', msg: 'Message handler failed', error: err.message }));
            }
          }));
        } catch (err) {
          console.error(JSON.stringify({ level: 'error', msg: 'SQS consume error', error: err.message }));
          await new Promise((r) => setTimeout(r, 5000));
        }
      }
    },
  };
}

// ─── Export ─────────────────────────────────────────────────────────────────

const queue = config.queue.driver === 'sqs' ? createSqsQueue() : createRedisQueue();

module.exports = queue;
