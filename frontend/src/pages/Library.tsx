import React from 'react';

const Library: React.FC = () => {
  const [library, setLibrary] = React.useState<any[]>([]);

  React.useEffect(() => {
    fetch(`http://localhost:3001/api/library`, {
      credentials: 'include',
    })
      .then(res => res.json())
      .then(data => setLibrary(data));
  }, []);

  return (
    <div>
      <h1>My Library</h1>
      <div className="games-grid">
        {library.map(game => (
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

export default Library;
