const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;

app.use(cors());

app.get("/resource", (req, res) => {
  res.send({ name: "Graeme", pets: ["dog", "goldfish", "snake"] });
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
