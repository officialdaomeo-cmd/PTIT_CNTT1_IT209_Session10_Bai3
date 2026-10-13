const http = require('http');

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify({
    status: 'success',
    message: 'Hello from Multi-stage Container!',
    timestamp: new Date().toISOString()
  }));
});

server.listen(port, () => {
  console.log(`Server running at port ${port}`);
});
