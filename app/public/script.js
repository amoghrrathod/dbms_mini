// script.js
document.addEventListener('DOMContentLoaded', () => {
    const API_BASE_URL = 'http://localhost:3000/api';

    // DOM Elements
    const listPanel = document.getElementById('list-panel');
    const detailsPanel = document.getElementById('details-panel');
    const viewGamesBtn = document.getElementById('view-games-btn');
    const viewUsersBtn = document.getElementById('view-users-btn');

    let currentView = 'games'; // To track the active view

    // --- Event Listeners ---
    viewGamesBtn.addEventListener('click', () => switchView('games'));
    viewUsersBtn.addEventListener('click', () => switchView('users'));

    function switchView(view) {
        currentView = view;
        viewGamesBtn.classList.toggle('active', view === 'games');
        viewUsersBtn.classList.toggle('active', view === 'users');
        detailsPanel.innerHTML = '<p class="placeholder">Select an item from the left to see details.</p>';
        
        if (view === 'games') {
            loadGamesList();
        } else {
            loadUsersList();
        }
    }

    // --- Data Loading Functions ---
    async function fetchData(url) {
        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }
            return await response.json();
        } catch (error) {
            console.error("Failed to fetch data:", error);
            listPanel.innerHTML = `<h2>Error loading data. Is the server running?</h2>`;
            return [];
        }
    }

    async function loadGamesList() {
        listPanel.innerHTML = '<h2>Games</h2>';
        const games = await fetchData(`${API_BASE_URL}/games`);
        games.forEach(game => {
            const item = document.createElement('div');
            item.className = 'list-item';
            item.textContent = game.game_name;
            item.dataset.id = game.game_id;
            item.addEventListener('click', () => showGameDetails(game.game_id, item));
            listPanel.appendChild(item);
        });
    }

    async function loadUsersList() {
        listPanel.innerHTML = '<h2>Users</h2>';
        const users = await fetchData(`${API_BASE_URL}/users`);
        users.forEach(user => {
            const item = document.createElement('div');
            item.className = 'list-item';
            item.textContent = user.user_name;
            item.dataset.id = user.user_id;
            item.addEventListener('click', () => showUserDetails(user.user_id, item));
            listPanel.appendChild(item);
        });
    }

    // --- Detail Display Functions ---
    function setActiveItem(item) {
        document.querySelectorAll('.list-item').forEach(el => el.classList.remove('selected'));
        item.classList.add('selected');
    }

    async function showGameDetails(gameId, element) {
        setActiveItem(element);
        const data = await fetchData(`${API_BASE_URL}/games/${gameId}`);
        if (!data.details) return;

        const { details, reviews, average_rating } = data;
        let reviewsHtml = '<div class="reviews-section"><h3>Reviews</h3>';
        if (reviews.length > 0) {
            reviews.forEach(review => {
                reviewsHtml += `
                    <div class="review-card">
                        <p class="rating">Rating: ${review.rating} / 5</p>
                        <p>"${review.review_text}"</p>
                        <p><em>- ${review.user_name}</em></p>
                    </div>
                `;
            });
        } else {
            reviewsHtml += '<p>No reviews yet for this game.</p>';
        }
        reviewsHtml += '</div>';
        
        const avgRatingText = average_rating ? `⭐ ${parseFloat(average_rating).toFixed(2)} / 5.00` : 'Not Rated';

        detailsPanel.innerHTML = `
            <h2>${details.game_name}</h2>
            <p><strong>Average Rating:</strong> ${avgRatingText}</p>
            <p><strong>Description:</strong> ${details.description}</p>
            <p><strong>Price:</strong> $${details.price}</p>
            <p><strong>Release Date:</strong> ${new Date(details.release_date).toLocaleDateString()}</p>
            <p><strong>Age Rating:</strong> ${details.age_rating}</p>
            <p><strong>Publisher:</strong> ${details.publisher_name || 'N/A'}</p>
            <p><strong>Developer:</strong> ${details.studio || 'N/A'}</p>
            ${reviewsHtml}
        `;
    }

    async function showUserDetails(userId, element) {
        setActiveItem(element);
        const library = await fetchData(`${API_BASE_URL}/users/${userId}/library`);
        
        let libraryHtml = '<h3>Game Library</h3>';
        if (library.length > 0) {
            libraryHtml += '<ul>';
            library.forEach(game => {
                libraryHtml += `<li>${game.game_name} (${game.hours_played} hours played)</li>`;
            });
            libraryHtml += '</ul>';
        } else {
            libraryHtml += '<p>This user does not own any games yet.</p>';
        }

        const userName = element.textContent;
        detailsPanel.innerHTML = `
            <h2>${userName}</h2>
            ${libraryHtml}
        `;
    }

    // --- Initial Load ---
    loadGamesList();
});
