import React from 'react';
import { useParams } from 'react-router-dom';

const GamePage: React.FC<{ user: any }> = ({ user }) => {
  const { id } = useParams<{ id: string }>();
  const [game, setGame] = React.useState<any>(null);
  const [reviews, setReviews] = React.useState<any[]>([]);
  const [items, setItems] = React.useState<any[]>([]);
  const [userOwnsGame, setUserOwnsGame] = React.useState(false);
  const [rating, setRating] = React.useState(5);
  const [reviewText, setReviewText] = React.useState('');

  React.useEffect(() => {
    fetch(`http://localhost:3001/api/games/${id}`)
      .then(res => res.json())
      .then(data => setGame(data));

    fetch(`http://localhost:3001/api/games/${id}/reviews`)
      .then(res => res.json())
      .then(data => setReviews(data));

    fetch(`http://localhost:3001/api/games/${id}/items`)
      .then(res => res.json())
      .then(data => setItems(data));

    if (user) {
      fetch(`http://localhost:3001/api/users/${user.user_id}/library`, {
        credentials: 'include',
      })
        .then(res => res.json())
        .then(library => {
          if (Array.isArray(library)) {
            const gameIds = library.map(game => game.game_id);
            setUserOwnsGame(gameIds.includes(parseInt(id, 10)));
          }
        });
    }
  }, [id, user]);

  const handleBuy = () => {
    fetch('http://localhost:3001/api/buy-game', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify({ gameId: id }),
    })
      .then(res => {
        if (res.ok) {
          alert('Game purchased successfully!');
          setUserOwnsGame(true);
        } else {
          alert('Failed to purchase game.');
        }
      });
  };

  const handleReviewSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetch(`http://localhost:3001/api/games/${id}/reviews`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      credentials: 'include',
      body: JSON.stringify({ rating, review_text: reviewText }),
    })
      .then(res => {
        if (res.ok) {
          alert('Review submitted successfully!');
          fetch(`http://localhost:3001/api/games/${id}/reviews`)
            .then(res => res.json())
            .then(data => setReviews(data));
        } else {
          res.text().then(text => alert(`Failed to submit review: ${text}`));
        }
      });
  };

  if (!game) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>{game.game_name}</h1>
      <p>{game.description}</p>
      <p><a href={`/publishers/${game.publisher_id}`}>Publisher</a></p>
      <p><a href={`/developers/${game.dev_id}`}>Developer</a></p>
      {!userOwnsGame && <button className="btn btn-success" onClick={handleBuy}>Buy</button>}

      <h2>Reviews</h2>
      {userOwnsGame && (
        <form onSubmit={handleReviewSubmit}>
          <div className="mb-3">
            <label htmlFor="rating" className="form-label">Rating</label>
            <select
              id="rating"
              className="form-select"
              value={rating}
              onChange={e => setRating(parseInt(e.target.value, 10))}
            >
              <option value="1">1</option>
              <option value="2">2</option>
              <option value="3">3</option>
              <option value="4">4</option>
              <option value="5">5</option>
            </select>
          </div>
          <div className="mb-3">
            <label htmlFor="reviewText" className="form-label">Review</label>
            <textarea
              id="reviewText"
              className="form-control"
              rows={3}
              value={reviewText}
              onChange={e => setReviewText(e.target.value)}
            ></textarea>
          </div>
          <button type="submit" className="btn btn-primary">Submit Review</button>
        </form>
      )}
      <ul className="list-group mt-3">
        {reviews.map(review => (
          <li key={review.review_id} className="list-group-item">
            <h5>{review.user_name}</h5>
            <p>Rating: {review.rating}</p>
            <p>{review.review_text}</p>
          </li>
        ))}
      </ul>

      <h2>Items</h2>
      <ul className="list-group">
        {items.map(item => (
          <li key={item.item_id} className="list-group-item">
            <h5>{item.item_name}</h5>
            <p>{item.description}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default GamePage;
