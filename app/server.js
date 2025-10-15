// server.js (Corrected Purchase Route)
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;

const dbConfig = { host: 'localhost', user: 'user1', password: '', database: 'gamestoredb' };

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

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// --- API Routes ---
app.post('/api/users/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(401).json({ message: 'Invalid credentials.' });
        const user = users[0];
        if (password === user.password) {
            res.json({ message: 'Login successful!', user: { userId: user.user_id, userName: user.user_name } });
        } else {
            res.status(401).json({ message: 'Invalid credentials.' });
        }
    } catch (error) { res.status(500).json({ message: 'Server error' }); }
});

app.post('/api/users/register', async (req, res) => {
    const { user_name, email, password, dob } = req.body;
    try {
        await db.query('INSERT INTO users (user_name, email, password, dob) VALUES (?, ?, ?, ?)', [user_name, email, password, dob || null]);
        res.status(201).json({ message: 'User created successfully!' });
    } catch (error) { res.status(500).json({ message: 'Error registering user' }); }
});

// --- CORRECTED Purchase Route ---
app.post('/api/library/purchase', async (req, res) => {
    const { userId, gameId } = req.body;
    try {
        await db.query('INSERT INTO user_library (user_id, game_id, purchase_date) VALUES (?, ?, NOW())', [userId, gameId]);
        res.status(201).json({ message: 'Game purchased successfully!' });
    } catch (error) {
        // This check handles the case where the user already owns the game (duplicate primary key)
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: 'You already own this game.' });
        }
        res.status(500).json({ message: 'Error purchasing game' });
    }
});

app.get('/api/games', async (req, res) => {
    const [rows] = await db.query('SELECT game_id, game_name, price FROM games ORDER BY game_name');
    res.json(rows);
});

app.get('/api/games/:id', async (req, res) => {
    const gameId = req.params.id;
    const userId = req.query.userId;
    try {
        const [gameDetailsRows] = await db.query('SELECT game_name, description, price FROM games WHERE game_id = ?', [gameId]);
        if (gameDetailsRows.length === 0) return res.status(404).json({ message: 'Game not found' });
        const [tags] = await db.query(`SELECT t.tag_name FROM tags t JOIN has_tags ht ON t.tag_id = ht.tag_id WHERE ht.game_id = ?`, [gameId]);
        let isOwned = false;
        if (userId) {
            const [libraryCheck] = await db.query('SELECT COUNT(*) as count FROM user_library WHERE user_id = ? AND game_id = ?', [userId, gameId]);
            if (libraryCheck[0].count > 0) isOwned = true;
        }
        res.json({ details: gameDetailsRows[0], tags: tags.map(t => t.tag_name), isOwned: isOwned });
    } catch (error) { res.status(500).json({ message: 'Server error fetching game details' }); }
});

app.get('/api/users/:userId/library', async (req, res) => {
    const { userId } = req.params;
    try {
        const [library] = await db.query(`SELECT g.game_id, g.game_name FROM user_library ul JOIN games g ON ul.game_id = g.game_id WHERE ul.user_id = ? ORDER BY g.game_name;`, [userId]);
        res.json(library);
    } catch (error) { res.status(500).json({ message: 'Server error' }); }
});

app.get('/api/users/:userId/achievements', async (req, res) => {
    const { userId } = req.params;
    try {
        const query = `
            SELECT g.game_name, a.achievement_name, a.description, a.unlock_timestamp
            FROM achievements a
            JOIN games g ON a.game_id = g.game_id
            WHERE a.user_id = ?
            ORDER BY g.game_name, a.unlock_timestamp DESC;
        `;
        const [achievements] = await db.query(query, [userId]);
        res.json(achievements);
    } catch (error) { res.status(500).json({ message: 'Server error fetching achievements' }); }
});

async function startServer() {
    await connectToDatabase();
    app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
}
startServer();
