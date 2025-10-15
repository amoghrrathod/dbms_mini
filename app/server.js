// server.js (Most Basic Version - NO SECURITY)
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

// --- Database Configuration ---
const dbConfig = {
    host: 'localhost',
    user: 'user1',
    password: '',
    database: 'gamestoredb'
};

let db;
async function connectToDatabase() {
    try {
        db = await mysql.createPool(dbConfig);
        console.log('✅ Successfully connected to the database.');
    } catch (error) {
        console.error('❌ Error connecting to the database:', error);
        process.exit(1);
    }
}

// --- Middleware ---
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));


// --- API Routes ---

// LOGIN: Checks plain text password against plain text in DB.
app.post('/api/users/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ message: 'Invalid credentials.' });
        }
        const user = users[0];

        // Simple string comparison.
        if (password === user.password) {
            res.json({
                message: 'Login successful!',
                user: {
                    userId: user.user_id,
                    userName: user.user_name
                }
            });
        } else {
            res.status(401).json({ message: 'Invalid credentials.' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Server error' });
    }
});

// REGISTER: Saves the plain text password directly to the DB.
app.post('/api/users/register', async (req, res) => {
    const { user_name, email, password, dob } = req.body;
    try {
        const query = 'INSERT INTO users (user_name, email, password, dob) VALUES (?, ?, ?, ?)';
        await db.query(query, [user_name, email, password, dob || null]);
        res.status(201).json({ message: 'User created successfully! Please log in.' });
    } catch (error) {
        res.status(500).json({ message: 'Error registering user' });
    }
});


// PURCHASE: Trusts the userId sent from the frontend.
app.post('/api/library/purchase', async (req, res) => {
    const { userId, gameId } = req.body;
    if (!userId || !gameId) {
        return res.status(400).json({ message: 'User ID and Game ID are required.' });
    }
    try {
        const query = 'INSERT INTO user_library (user_id, game_id, purchase_date) VALUES (?, ?, NOW())';
        await db.query(query, [userId, gameId]);
        res.status(201).json({ message: 'Game purchased successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Error purchasing game' });
    }
});

// GET all games.
app.get('/api/games', async (req, res) => {
    const [rows] = await db.query('SELECT game_id, game_name, price FROM games ORDER BY game_name');
    res.json(rows);
});

// GET game details.
app.get('/api/games/:id', async (req, res) => {
    const gameId = req.params.id;
    const [gameDetails] = await db.query(
        'SELECT game_name, description, price FROM games WHERE game_id = ?',
        [gameId]
    );
    res.json({ details: gameDetails.length > 0 ? gameDetails[0] : null });
});

// --- Start Server ---
async function startServer() {
    await connectToDatabase();
    app.listen(PORT, () => {
        console.log(`🚀 Server running at http://localhost:${PORT}`);
    });
}

startServer();
