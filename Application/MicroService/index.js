const express = require("express");
const app = express();
const port = 3000;

app.get("/resource", (req, res) => {
  res.send({ name: "Graeme", pets: ["dog"] });
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
