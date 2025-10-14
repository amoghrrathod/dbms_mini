import React from 'react';
import { useParams } from 'react-router-dom';

const GamePage: React.FC<{ user: any }> = ({ user }) => {
  const { id } = useParams<{ id: string }>();
  const [game, setGame] = React.useState<any>(null);
  const [reviews, setReviews] = React.useState<any[]>([]);
  const [items, setItems] = React.useState<any[]>([]);

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
  }, [id]);

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
        } else {
          alert('Failed to purchase game.');
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
      <button className="btn btn-success" onClick={handleBuy}>Buy</button>

      <h2>Reviews</h2>
      <ul className="list-group">
        {reviews.map(review => (
          <li key={review.review_id} className="list-group-item">
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
