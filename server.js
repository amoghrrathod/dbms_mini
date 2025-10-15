const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const session = require("express-session");
const app = express();
const port = 3001;

app.use(cors({ origin: `http://localhost:5173`, credentials: true }));
app.use(express.json());
app.use(
  session({
    secret: "a-secret-key-to-sign-the-cookie",
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false },
  }),
);
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

const requireAuth = (req, res, next) => {
  if (req.session.user) {
    next();
  } else {
    res.status(401).send("Unauthorized");
  }
};

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

app.post("/api/buy-game", requireAuth, (req, res) => {
  const { gameId } = req.body;
  const userId = req.session.user.user_id;
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

app.get("/api/games/:gameId/achievements/user/:userId", (req, res) => {
  const { gameId, userId } = req.params;
  const query = `
    SELECT ga.achievement_id, ga.achievement_name, ga.description, ua.unlocked_achievement_id IS NOT NULL AS unlocked
    FROM game_achievements ga
    LEFT JOIN unlocked_achievements ua ON ga.achievement_id = ua.achievement_id AND ua.user_id = ?
    WHERE ga.game_id = ?;
  `;
  db.query(query, [userId, gameId], (err, results) => {
    if (err) {
      console.error("Error fetching achievements with user status:", err);
      res.status(500).send("Error fetching achievements");
      return;
    }
    res.json(results);
  });
});

app.get("/api/games/:id/reviews", (req, res) => {
  const gameId = req.params.id;
  db.query(
    "SELECT r.*, u.user_name FROM reviews r JOIN users u ON r.user_id = u.user_id WHERE game_id = ?",
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

app.post("/api/games/:id/reviews", requireAuth, (req, res) => {
  const gameId = req.params.id;
  const userId = req.session.user.user_id;
  const { rating, review_text } = req.body;

  db.query(
    "INSERT INTO reviews (user_id, game_id, rating, review_text) VALUES (?, ?, ?, ?)",
    [userId, gameId, rating, review_text],
    (err, results) => {
      if (err) {
        console.error("Error inserting review:", err);
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(409).send('You have already reviewed this game.');
        }
        res.status(500).send("Error inserting review");
        return;
      }
      res.status(201).send("Review added successfully");
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

app.get("/api/users/:id/friends", requireAuth, (req, res) => {
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

app.get("/api/users/:id/library", requireAuth, (req, res) => {
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

app.get("/api/users/:id/achievements", requireAuth, (req, res) => {
  const userId = req.params.id;
  db.query(
    `SELECT ga.*, g.game_name
    FROM game_achievements ga
    JOIN unlocked_achievements ua ON ga.achievement_id = ua.achievement_id
    JOIN games g ON ga.game_id = g.game_id
    WHERE ua.user_id = ?`,
    [userId],
    (err, results) => {
      if (err) {
        res.status(500).send("Error fetching user achievements");
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

app.post("/api/login", (req, res) => {
  const { user_name, password } = req.body;
  db.query(
    "SELECT * FROM users WHERE user_name = ? AND password = ?",
    [user_name, password],
    (err, results) => {
      if (err) {
        res.status(500).send("Error logging in");
        return;
      }
      if (results.length > 0) {
        req.session.user = results[0];
        res.json({ loggedIn: true, user: results[0] });
      } else {
        res.status(401).send("Invalid credentials");
      }
    },
  );
});

app.get("/api/logout", requireAuth, (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      res.status(500).send("Error logging out");
      return;
    }
    res.send("Logged out");
  });
});

app.get("/api/check-session", (req, res) => {
  if (req.session.user) {
    res.json({ loggedIn: true, user: req.session.user });
  } else {
    res.json({ loggedIn: false });
  }
});

app.get("/", (req, res) => {
  res.send("Hello from the backend!");
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
