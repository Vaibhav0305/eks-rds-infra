const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection (optional — if you want to connect to RDS later)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // this will be set in Kubernetes later
});

// Health check route
app.get('/', (req, res) => res.json({ status: 'ok' }));

// Example: check database time
app.get('/time', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ time: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`API server running on port ${port}`);
});
