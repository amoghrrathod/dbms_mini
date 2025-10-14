const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "password",
  database: "gamestoredb",
});

db.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err);
    return;
  }
  console.log("Connected to the MySQL database.");
});

app.get("/api/developers/:id/games", (req, res) => {
  const devId = req.params.id;
  db.query("SELECT * FROM games WHERE dev_id = ?", [devId], (err, results) => {
    if (err) {
      res.status(500).send("Error fetching games by developer");
      return;
    }
    res.json(results);
  });
});

app.get("/api/publishers/:id/games", (req, res) => {
  const publisherId = req.params.id;
  db.query(
    "SELECT * FROM games WHERE publisher_id = ?",
    [publisherId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching games by publisher");
        return;
      }
      res.json(results);
    },
  );
});

app.post("/api/buy-game", (req, res) => {
  const { userId, gameId } = req.body;
  db.query(
    "INSERT INTO user_library (user_id, game_id, purchase_date) VALUES (?, ?, NOW())",
    [userId, gameId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error buying game");
        return;
      }
      res.status(200).send("Game purchased successfully");
    },
  );
});

app.get("/api/games/:id/items", (req, res) => {
  const gameId = req.params.id;
  db.query(
    "SELECT * FROM items WHERE game_id = ?",
    [gameId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching items");
        return;
      }
      res.json(results);
    },
  );
});

app.get("/api/games/:id/reviews", (req, res) => {
  const gameId = req.params.id;
  db.query(
    "SELECT * FROM reviews WHERE game_id = ?",
    [gameId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching reviews");
        return;
      }
      res.json(results);
    },
  );
});

app.get("/api/games/:id", (req, res) => {
  const gameId = req.params.id;
  db.query(
    "SELECT * FROM games WHERE game_id = ?",
    [gameId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching game");
        return;
      }
      res.json(results[0]);
    },
  );
});

app.get("/api/users/:id/friends", (req, res) => {
  const userId = req.params.id;
  db.query(
    `SELECT u.user_id, u.user_name
    FROM users u
    JOIN friendships f ON (u.user_id = f.user_id2 AND f.user_id1 = ?) OR (u.user_id = f.user_id1 AND f.user_id2 = ?)`,
    [userId, userId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching user friends");
        return;
      }
      res.json(results);
    },
  );
});

app.get("/api/users/:id/library", (req, res) => {
  const userId = req.params.id;
  db.query(
    `SELECT g.*
    FROM games g
    JOIN user_library ul ON g.game_id = ul.game_id
    WHERE ul.user_id = ?`,
    [userId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching user library");
        return;
      }
      res.json(results);
    },
  );
});

app.get("/api/games/tag/:tagName", (req, res) => {
  const tagName = req.params.tagName;
  db.query("CALL get_games_by_tag(?)", [tagName], (err, results) => {
    if (err) {
      res.status(500).send("Error fetching games by tag");
      return;
    }
    res.json(results[0]);
  });
});

app.get("/api/tags", (req, res) => {
  db.query("SELECT * FROM tags", (err, results) => {
    if (err) {
      res.status(500).send("Error fetching tags");
      return;
    }
    res.json(results);
  });
});

app.get("/api/search", (req, res) => {
  const query = req.query.q;
  db.query(
    `SELECT g.*, GROUP_CONCAT(t.tag_name) AS tags
    FROM games g
    LEFT JOIN has_tags ht ON g.game_id = ht.game_id
    LEFT JOIN tags t ON ht.tag_id = t.tag_id
    WHERE g.game_name LIKE ? OR t.tag_name LIKE ?
    GROUP BY g.game_id`,
    [`%${query}%`, `%${query}%`],
    (err, results) => {
      if (err) {
        res.status(500).send("Error searching games");
        return;
      }
      res.json(results);
    },
  );
});

app.get("/api/games", (req, res) => {
  db.query("SELECT * FROM games", (err, results) => {
    if (err) {
      res.status(500).send("Error fetching games");
      return;
    }
    res.json(results);
  });
});

app.get("/", (req, res) => {
  res.send("Hello from the backend!");
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
