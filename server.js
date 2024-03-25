const express = require('express');
const app = express();
const port = 8000;

const processId = "2gM9n9QO6JG1_bZhCWr3fuEKJtzRgx1xvYUB92nVFAs";

app.use(express.static('src', {
  setHeaders: (res, path, stat) => {
    res.set('x-arns-resolved-id', processId);
  }
}));

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});