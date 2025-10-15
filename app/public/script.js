document.addEventListener('DOMContentLoaded', () => {
    const loggedInUserString = localStorage.getItem('loggedInUser');
    if (!loggedInUserString) {
        window.location.href = '/login.html';
        return;
    }
    const loggedInUser = JSON.parse(loggedInUserString);

    const listPanel = document.getElementById('list-panel');
    const detailsPanel = document.getElementById('details-panel');
    const usernameSpan = document.getElementById('username');
    const logoutBtn = document.getElementById('logout-btn');
    const navButtons = {
        library: document.getElementById('btn-library'),
        store: document.getElementById('btn-store'),
        achievements: document.getElementById('btn-achievements')
    };

    document.getElementById('user-info').classList.remove('hidden');
    usernameSpan.textContent = loggedInUser.userName;
    logoutBtn.addEventListener('click', () => {
        localStorage.removeItem('loggedInUser');
        window.location.href = '/login.html';
    });

    // View Switching Logic...
    navButtons.library.addEventListener('click', () => switchView('library'));
    navButtons.store.addEventListener('click', () => switchView('store'));
    navButtons.achievements.addEventListener('click', () => switchView('achievements'));
    function switchView(view) {
        detailsPanel.innerHTML = '<p class="placeholder">Select an item</p>';
        detailsPanel.style.display = 'block';
        listPanel.style.flex = '1';
        Object.values(navButtons).forEach(btn => btn.classList.remove('active'));
        navButtons[view].classList.add('active');
        if (view === 'library') loadUserLibrary();
        if (view === 'store') loadStoreGames();
        if (view === 'achievements') loadUserAchievements();
    }

    // Data Loading Functions...
    async function loadUserLibrary() {
        const response = await fetch(`/api/users/${loggedInUser.userId}/library`);
        const games = await response.json();
        renderGameList('My Library', games);
    }
    async function loadStoreGames() {
        const response = await fetch(`/api/games`);
        const games = await response.json();
        renderGameList('Store', games);
    }
    async function loadUserAchievements() {
        listPanel.style.flex = '3';
        detailsPanel.style.display = 'none';
        const response = await fetch(`/api/users/${loggedInUser.userId}/achievements`);
        const achievements = await response.json();
        let html = '<h2>My Achievements</h2>';
        if (Array.isArray(achievements) && achievements.length > 0) {
            const achievementsByGame = achievements.reduce((acc, ach) => {
                if (!acc[ach.game_name]) acc[ach.game_name] = [];
                acc[ach.game_name].push(ach);
                return acc;
            }, {});
            html += '<div class="achievements-list">';
            for (const gameName in achievementsByGame) {
                html += `<h3>${gameName}</h3>`;
                achievementsByGame[gameName].forEach(ach => {
                    html += `<div class="achievement-item"><strong>${ach.achievement_name}</strong>: ${ach.description}<br><small>Unlocked on: ${new Date(ach.unlock_timestamp).toLocaleDateString()}</small></div>`;
                });
            }
            html += '</div>';
        } else {
            html += '<p>You have not unlocked any achievements yet.</p>';
        }
        listPanel.innerHTML = html;
    }

    // Rendering Functions...
    function renderGameList(title, games) {
        let html = `<h2>${title}</h2>`;
        if (games.length > 0) {
            games.forEach(game => {
                html += `<div class="list-item" data-id="${game.game_id}">${game.game_name}</div>`;
            });
        } else {
            html += '<p>No games to display.</p>';
        }
        listPanel.innerHTML = html;
    }
    async function showGameDetails(gameId) {
        const response = await fetch(`/api/games/${gameId}?userId=${loggedInUser.userId}`);
        const data = await response.json();
        if (!data.details) return;
        const { details, tags, isOwned } = data;
        let tagsHtml = tags.map(tag => `<span class="tag">${tag}</span>`).join('');
        detailsPanel.innerHTML = `
            <h2>${details.game_name}</h2>
            <p>${details.description || 'No description available.'}</p>
            <p><strong>Price:</strong> $${details.price}</p>
            <div class="tags-container"><strong>Tags:</strong> ${tagsHtml || 'None'}</div>
            <button class="purchase-btn" data-game-id="${gameId}" ${isOwned ? 'disabled' : ''}>
                ${isOwned ? 'In Your Library' : `Purchase for $${details.price}`}
            </button>
        `;
    }

    // Event Delegation...
    listPanel.addEventListener('click', (event) => {
        if (event.target.classList.contains('list-item')) {
            showGameDetails(event.target.dataset.id);
        }
    });
    
    // --- CORRECTED Event Listener ---
    detailsPanel.addEventListener('click', async (event) => {
        if (event.target.classList.contains('purchase-btn') && !event.target.disabled) {
            const purchaseBtn = event.target;
            // The HTML attribute is 'data-game-id', so in JS it becomes 'dataset.gameId'
            const gameId = purchaseBtn.dataset.gameId; 
            purchaseBtn.textContent = 'Processing...';
            purchaseBtn.disabled = true;

            const response = await fetch(`/api/library/purchase`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId: loggedInUser.userId, gameId: gameId })
            });

            // If the purchase fails (e.g., user already owns it), show the server's message
            if (!response.ok) {
                const result = await response.json();
                alert(result.message);
            }

            // Refresh the details to show the "In Your Library" state
            showGameDetails(gameId);
        }
    });

    // Initial Load
    loadUserLibrary();
});
