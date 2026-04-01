require('dotenv').config();
const express = require('express');
const path = require('path');


const app = express();

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// API routes
const apiRoutes = require('./routes/api');
app.use('/api', apiRoutes);

// Page routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/html/index.html'));
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

require('dotenv').config();