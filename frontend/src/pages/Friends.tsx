import React from 'react';

const Friends: React.FC<{ user: any }> = ({ user }) => {
  const [friends, setFriends] = React.useState<any[]>([]);

  React.useEffect(() => {
    if (user) {
      fetch(`http://localhost:3001/api/users/${user.user_id}/friends`, {
        credentials: 'include',
      })
        .then(res => res.json())
        .then(data => setFriends(data));
    }
  }, [user]);

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
