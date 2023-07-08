const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

app.get("/", (res) => res.send("The app is up and running!"));
app.listen(port, () => console.log(`The app is listening on port ${port}.`));
