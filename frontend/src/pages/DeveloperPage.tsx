import React from 'react';
import { useParams } from 'react-router-dom';

const DeveloperPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [games, setGames] = React.useState<any[]>([]);

  React.useEffect(() => {
    fetch(`http://localhost:3001/api/developers/${id}/games`)
      .then(res => res.json())
      .then(data => setGames(data));
  }, [id]);

  return (
    <div>
      <h1>Developer Games</h1>
      <div className="games-grid">
        {games.map(game => (
          <div key={game.game_id} className="card" style={{width: '18rem'}}>
            <div className="card-body">
              <h5 className="card-title">{game.game_name}</h5>
              <p className="card-text">{game.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default DeveloperPage;
