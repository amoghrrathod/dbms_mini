// server.js
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

// --- Database Configuration ---
// !!! IMPORTANT: Replace with your own MySQL credentials !!!
const dbConfig = {
    host: 'localhost',
    user: 'user1',
    password: '', // <-- CHANGE THIS
    database: 'gamestoredb'
};

let db;

async function connectToDatabase() {
    try {
        db = await mysql.createPool(dbConfig);
        console.log('✅ Successfully connected to the database.');
    } catch (error) {
        console.error('❌ Error connecting to the database:', error);
        process.exit(1); // Exit if DB connection fails
    }
}

// --- Middleware ---
app.use(cors());
app.use(express.json());
// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));


// --- API Routes ---

// GET all games (basic info)
app.get('/api/games', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT game_id, game_name, price FROM games ORDER BY game_name');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching games', error });
    }
});

// GET details for a single game (including reviews)
app.get('/api/games/:id', async (req, res) => {
    try {
        const gameId = req.params.id;

        const [gameDetails] = await db.query(`
            SELECT g.game_name, g.description, g.release_date, g.price, g.age_rating, p.publisher_name, d.studio
            FROM games g
            LEFT JOIN publishers p ON g.publisher_id = p.publisher_id
            LEFT JOIN developers d ON g.dev_id = d.dev_id
            WHERE g.game_id = ?`, [gameId]);

        if (gameDetails.length === 0) {
            return res.status(404).json({ message: 'Game not found' });
        }

        const [reviews] = await db.query(`
            SELECT r.rating, r.review_text, u.user_name
            FROM reviews r
            JOIN users u ON r.user_id = u.user_id
            WHERE r.game_id = ?
            ORDER BY r.post_date DESC`, [gameId]);

        // Use the SQL function you created
        const [[avgRatingResult]] = await db.query('SELECT get_average_game_rating(?) AS avg_rating', [gameId]);


        res.json({
            details: gameDetails[0],
            reviews: reviews,
            average_rating: avgRatingResult.avg_rating
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching game details', error });
    }
});

// GET all users
app.get('/api/users', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT user_id, user_name, email FROM users ORDER BY user_name');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users', error });
    }
});

// GET a single user's library
app.get('/api/users/:id/library', async (req, res) => {
    try {
        const userId = req.params.id;
        const [library] = await db.query(`
            SELECT g.game_name, ul.purchase_date, ul.hours_played
            FROM user_library ul
            JOIN games g ON ul.game_id = g.game_id
            WHERE ul.user_id = ?
            ORDER BY g.game_name`, [userId]);

        if (library.length === 0) {
            // It's not an error if the library is empty, just return an empty array
        }
        res.json(library);

    } catch (error) {
        res.status(500).json({ message: 'Error fetching user library', error });
    }
});


// --- Start Server ---
async function startServer() {
    await connectToDatabase();
    app.listen(PORT, () => {
        console.log(`🚀 Server running at http://localhost:${PORT}`);
    });
}

startServer();
