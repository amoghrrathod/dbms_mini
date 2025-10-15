document.addEventListener('DOMContentLoaded', () => {
    const loggedInUserString = localStorage.getItem('loggedInUser');
    if (!loggedInUserString) {
        window.location.href = '/login.html';
        return;
    }
    const loggedInUser = JSON.parse(loggedInUserString);

    const listPanel = document.getElementById('list-panel');
    const detailsPanel = document.getElementById('details-panel');
    const userInfoDiv = document.getElementById('user-info');
    const usernameSpan = document.getElementById('username');
    const logoutBtn = document.getElementById('logout-btn');

    usernameSpan.textContent = loggedInUser.userName;
    userInfoDiv.classList.remove('hidden');

    logoutBtn.addEventListener('click', () => {
        localStorage.removeItem('loggedInUser');
        window.location.href = '/login.html';
    });

    detailsPanel.addEventListener('click', async (event) => {
        if (event.target.classList.contains('purchase-btn')) {
            const purchaseBtn = event.target;
            const gameId = purchaseBtn.dataset.gameId;
            purchaseBtn.textContent = 'Processing...';
            purchaseBtn.disabled = true;

            const response = await fetch(`/api/library/purchase`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId: loggedInUser.userId, gameId: gameId })
            });
            const result = await response.json();
            if (response.ok) {
                purchaseBtn.textContent = 'Added to Library!';
            } else {
                alert(result.message);
                purchaseBtn.disabled = false;
                purchaseBtn.textContent = `Purchase Game`;
            }
        }
    });

    async function loadGamesList() {
        const response = await fetch(`/api/games`);
        const games = await response.json();
        listPanel.innerHTML = '<h2>Games</h2>';
        games.forEach(game => {
            const item = document.createElement('div');
            item.className = 'list-item';
            item.textContent = game.game_name;
            item.dataset.id = game.game_id;
            item.addEventListener('click', () => showGameDetails(game.game_id));
            listPanel.appendChild(item);
        });
    }

    async function showGameDetails(gameId) {
        const response = await fetch(`/api/games/${gameId}`);
        const data = await response.json();
        const details = data.details;
        detailsPanel.innerHTML = `
            <h2>${details.game_name}</h2>
            <p>${details.description || 'No description available.'}</p>
            <p><strong>Price:</strong> $${details.price}</p>
            <button class="purchase-btn" data-game-id="${gameId}">Purchase for $${details.price}</button>
        `;
    }

    loadGamesList();
});
