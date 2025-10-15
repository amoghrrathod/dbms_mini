import React from 'react';

const Library: React.FC<{ user: any }> = ({ user }) => {
  const [library, setLibrary] = React.useState<any[]>([]);
  const [expandedGame, setExpandedGame] = React.useState<number | null>(null);
  const [achievements, setAchievements] = React.useState<any[]>([]);

  React.useEffect(() => {
    if (user) {
      fetch(`http://localhost:3001/api/users/${user.user_id}/library`, {
        credentials: 'include',
      })
        .then(res => res.json())
        .then(data => setLibrary(data));
    }
  }, [user]);

  const handleGameClick = (gameId: number) => {
    if (expandedGame === gameId) {
      setExpandedGame(null);
      setAchievements([]);
    } else {
      fetch(`http://localhost:3001/api/games/${gameId}/achievements/user/${user.user_id}`, {
        credentials: 'include',
      })
        .then(res => res.json())
        .then(data => {
          setAchievements(data);
          setExpandedGame(gameId);
        });
    }
  };

  const unlockedAchievementsCount = achievements.filter(a => a.unlocked).length;

  return (
    <div>
      <h1>My Library</h1>
      <div className="games-grid">
        {library.map(game => (
          <div key={game.game_id} className="card" style={{width: '18rem'}}>
            <div className="card-body">
              <h5 className="card-title" onClick={() => handleGameClick(game.game_id)} style={{cursor: 'pointer'}}>{game.game_name}</h5>
              <p className="card-text">{game.description}</p>
              {expandedGame === game.game_id && (
                <div>
                  <h6>Achievements ({unlockedAchievementsCount}/{achievements.length})</h6>
                  <ul className="list-group">
                    {achievements.map(ach => (
                      <li key={ach.achievement_id} className="list-group-item">
                        {ach.achievement_name} {ach.unlocked ? '✔️' : ''}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Library;
