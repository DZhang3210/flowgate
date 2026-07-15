const express = require('express');

const app = express();

app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    // Skip logging /health to avoid noise in CloudWatch
    if (req.path === '/health') return;
    console.log(JSON.stringify({
      level:      'info',
      msg:        'HTTP request',
      method:     req.method,
      path:       req.path,
      status:     res.statusCode,
      latencyMs:  Date.now() - start,
      userAgent:  req.headers['user-agent'],
    }));
  });
  next();
});

// Routes
app.use('/',         require('./routes/health'));
app.use('/tenants',  require('./routes/tenants'));
app.use('/api',      require('./routes/api'));

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(JSON.stringify({ level: 'error', msg: 'Unhandled error', error: err.message, stack: err.stack }));
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;
