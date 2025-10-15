import React, { useState } from 'react';

interface LoginPageProps {
  onLogin: (user: any) => void;
}

const LoginPage: React.FC<LoginPageProps> = ({ onLogin }) => {
  const [user_name, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    if (user_name.trim() && password.trim()) {
      fetch("http://localhost:3001/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ user_name, password }),
        credentials: 'include',
      })
        .then((res) => {
          console.log("Response:", res);
          if (!res.ok) {
            throw new Error("Login failed");
          }
          return res.json();
        })
        .then((data) => {
          console.log("Data:", data);
          if (data.user) {
            onLogin(data.user);
          }
        })
        .catch((error) => {
          console.error("Login error:", error);
          alert("Login failed. Please check the username and password and try again.");
        });
    }
  };

  return (
    <div className="login-page">
      <h1>Login</h1>
      <input
        type="text"
        placeholder="Enter your username"
        value={user_name}
        onChange={(e) => setUsername(e.target.value)}
      />
      <input
        type="password"
        placeholder="Enter your password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
};

export default LoginPage;
