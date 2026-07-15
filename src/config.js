require('dotenv').config();

module.exports = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',

  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    database: process.env.DB_NAME || 'flowgate',
    user: process.env.DB_USER || 'flowgate',
    password: process.env.DB_PASSWORD || 'flowgate_secret',
  },

  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    password: process.env.REDIS_PASSWORD || undefined,
  },

  queue: {
    driver: process.env.QUEUE_DRIVER || 'redis',  // 'redis' | 'sqs'
    name: process.env.QUEUE_NAME || 'webhook-delivery',
    sqsQueueUrl: process.env.SQS_QUEUE_URL,
  },

  aws: {
    region: process.env.AWS_REGION || 'us-east-1',
  },

  // Rate limits: requests per minute per API key, by plan
  rateLimits: {
    free: 60,
    pro: 600,
    enterprise: 6000,
  },
};
