import React from 'react';

interface AchievementsPageProps {
  user: any;
}

const AchievementsPage: React.FC<AchievementsPageProps> = ({ user }) => {
  const [achievements, setAchievements] = React.useState<any[]>([]);

  React.useEffect(() => {
    if (user) {
      fetch(`http://localhost:3001/api/users/${user.user_id}/achievements`, {
        credentials: 'include',
      })
        .then(res => res.json())
        .then(data => setAchievements(data));
    }
  }, [user]);

  const groupedAchievements = achievements.reduce((acc, ach) => {
    const gameName = ach.game_name;
    if (!acc[gameName]) {
      acc[gameName] = [];
    }
    acc[gameName].push(ach);
    return acc;
  }, {} as Record<string, any[]>);

  return (
    <div>
      <h1>Achievements</h1>
      {Object.entries(groupedAchievements).map(([gameName, achievements]) => (
        <div key={gameName}>
          <h2>{gameName}</h2>
          <ul className="list-group">
            {achievements.map(ach => (
              <li key={ach.achievement_id} className="list-group-item">
                {ach.achievement_name}
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
};

export default AchievementsPage;
