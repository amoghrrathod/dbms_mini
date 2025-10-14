import React from 'react';

const Friends: React.FC = () => {
  const [friends, setFriends] = React.useState<any[]>([]);
  const userId = 1; // Hardcoded for now

  React.useEffect(() => {
    fetch(`http://localhost:3001/api/users/${userId}/friends`)
      .then(res => res.json())
      .then(data => setFriends(data));
  }, [userId]);

  return (
    <div>
      <h1>My Friends</h1>
      <ul className="list-group">
        {friends.map(friend => (
          <li key={friend.user_id} className="list-group-item">{friend.user_name}</li>
        ))}
      </ul>
    </div>
  );
};

export default Friends;
