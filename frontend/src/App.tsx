import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import "./App.css";
import SearchBar from "./components/SearchBar";
import Filter from "./components/Filter";
import Navbar from "./components/Navbar";
import Library from "./pages/Library";
import Friends from "./pages/Friends";
import LoginPage from "./pages/LoginPage";

import DeveloperPage from "./pages/DeveloperPage";
import PublisherPage from "./pages/PublisherPage";
import GamePage from "./pages/GamePage";

function App() {
  const [games, setGames] = React.useState<any[]>([]);
  const [tags, setTags] = React.useState<any[]>([]);
  const [user, setUser] = React.useState<any>(null);

  const handleSearch = (query: string) => {
    fetch(`http://localhost:3001/api/search?q=${query}`)
      .then((res) => res.json())
      .then((data) => setGames(data));
  };

  const handleFilter = (tagName: string) => {
    if (tagName) {
      fetch(`http://localhost:3001/api/games/tag/${tagName}`)
        .then((res) => res.json())
        .then((data) => {
          console.log('Filtered games:', data);
          setGames(data);
        });    } else {
      fetch("http://localhost:3001/api/games")
        .then((res) => res.json())
        .then((data) => setGames(data));
    }
  };

  React.useEffect(() => {
    fetch("http://localhost:3001/api/check-session", {
      credentials: "include",
    }).then((res) => res.json())
      .then((data) => {
        if (data.user) {
          setUser(data.user);
        }
      })
      .catch(() => setUser(null));

    fetch("http://localhost:3001/api/games")
      .then((res) => res.json())
      .then((data) => setGames(data));

    fetch("http://localhost:3001/api/tags")
      .then((res) => res.json())
      .then((data) => setTags(data));
  }, []);

  const handleLogin = (user: any) => {
    setUser(user);
  };

  if (!user) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return (
    <Router>
      <Navbar username={user.user_name} />
      <div className="container mt-4">
        <Routes>
          <Route
            path="/"
            element={
              <>
                <h1>Games</h1>
                <SearchBar onSearch={handleSearch} />
                <Filter tags={tags} onFilter={handleFilter} />
                <div className="row">
                  {games.map((game) => (
                    <div className="col-md-3 mb-4" key={game.game_id}>
                      <div className="card">
                        <div className="card-body">
                          <h5 className="card-title">{game.game_name}</h5>
                          <p className="card-text">{game.description}</p>
                          <a
                            href={`/games/${game.game_id}`}
                            className="btn btn-primary"
                          >
                            View Details
                          </a>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </>
            }
          />
          <Route path="/library" element={<Library />} />
          <Route path="/friends" element={<Friends />} />
          <Route path="/games/:id" element={<GamePage user={user} />} />
          <Route path="/publishers/:id" element={<PublisherPage />} />
          <Route path="/developers/:id" element={<DeveloperPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
