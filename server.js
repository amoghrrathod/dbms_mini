const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const session = require("express-session");

const app = express();
const port = 3001;

app.use(
  cors({
    origin: "http://localhost:5173", // frontend origin
    credentials: true,
  }),
);
app.use(express.json());
app.use(
  session({
    secret: "your-secret-key", // Replace with a real secret key
    resave: true,
    saveUninitialized: false,
    cookie: { secure: false }, // Set to true if using https
  }),
);

const fs = require("fs");

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "password",
  database: "gamestoredb",
  multipleStatements: true,
});

const sql = fs.readFileSync("./mini.sql").toString();

db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to the MySQL database.");

  db.query(sql, (err, results) => {
    if (err) {
      console.error("Error initializing database:", err);
      return;
    }
    console.log("Database initialized.");

    app.listen(port, () => {
      console.log(`Server is running on http://localhost:${port}`);
    });
  });
