DROP DATABASE IF EXISTS gamestoredb;
CREATE DATABASE gamestoredb;
USE gamestoredb;

-- ### Table Definitions ###

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    dob DATE,
    INDEX (user_name)
);

CREATE TABLE user_address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_lines TEXT,
    pincode VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
);

CREATE TABLE friendships (
    user_id1 INT NOT NULL,
    user_id2 INT NOT NULL,
    added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id1, user_id2),
    FOREIGN KEY (user_id1) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id2) REFERENCES users (user_id) ON DELETE CASCADE,
    CHECK (user_id1 < user_id2)
);

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(150) NOT NULL UNIQUE,
    country VARCHAR(100)
);

CREATE TABLE developers (
    dev_id INT AUTO_INCREMENT PRIMARY KEY,
    studio VARCHAR(150) NOT NULL,
    country VARCHAR(100)
);

CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE,
    parent_tag_id INT,
    FOREIGN KEY (parent_tag_id) REFERENCES tags (tag_id) ON DELETE SET NULL
);

CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_name VARCHAR(255) NOT NULL,
    description TEXT,
    release_date DATE,
    price DECIMAL(10, 2),
    age_rating VARCHAR(10),
    publisher_id INT,
    dev_id INT,
    FOREIGN KEY (publisher_id) REFERENCES publishers (publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (dev_id) REFERENCES developers (dev_id) ON DELETE SET NULL,
    INDEX (game_name)
);

CREATE TABLE has_tags (
    game_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (game_id, tag_id),
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags (tag_id) ON DELETE CASCADE
);

CREATE TABLE user_library (
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    purchase_date DATETIME,
    hours_played DECIMAL(10, 1) DEFAULT 0.0,
    PRIMARY KEY (user_id, game_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE
);

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    game_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT,
    post_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL,
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE,
    CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE achievements (
    achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    achievement_name VARCHAR(255) NOT NULL,
    description TEXT,
    unlock_timestamp DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE
);

CREATE TABLE items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    description TEXT,
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE
);

CREATE TABLE item_instances (
    instance_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    user_id INT,
    date_acquired DATETIME NOT NULL,
    FOREIGN KEY (item_id) REFERENCES items (item_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE SET NULL
);

-- ### Data Insertion ###

INSERT INTO users (user_name, email, password, dob) VALUES
('alice', 'alice@email.com', 'password123', '1995-04-12'),
('bob', 'bob@email.com', 'password456', '1998-07-22'),
('charlie', 'charlie@email.com', 'password789', '1992-11-30'),
('diana', 'diana@email.com', 'password101', '2001-01-15'),
('eva', 'eva@email.com', 'password5', '1999-02-20');

INSERT INTO publishers (publisher_name, country) VALUES
('PixelPush Inc.', 'USA'), ('GigaGames', 'Japan'), ('IndieDream Co.', 'Canada'),
('Quantum Leap Studios', 'USA'), ('Nebula Interactive', 'UK');

INSERT INTO developers (studio, country) VALUES
('Starlight Studios', 'USA'), ('CodeWizards', 'UK'), ('Lone Wolf Dev', 'Canada'),
('Celestial Forge', 'USA'), ('PixelHeart', 'Japan');

INSERT INTO games (game_name, description, release_date, price, age_rating, publisher_id, dev_id) VALUES
('Cybernetic Dawn', 'A thrilling sci-fi action RPG.', '2023-05-20', 59.99, '18+', 1, 1),
('Kingdoms of Ether', 'A vast open-world fantasy RPG.', '2022-11-10', 49.99, '16+', 1, 2),
('Puzzle Sphere', 'A relaxing and challenging puzzle game.', '2024-01-15', 19.99, '3+', 3, 3),
('Galactic Marauder', 'A fast-paced space strategy game.', '2023-08-01', 39.99, '12+', 2, 1);

INSERT INTO tags (tag_name) VALUES ('RPG'), ('Action'), ('Sci-Fi'), ('Puzzle'), ('Open World'), ('Strategy');

INSERT INTO has_tags (game_id, tag_id) VALUES
(1, 1), (1, 2), (1, 3), (2, 1), (2, 5), (3, 4), (4, 6);

INSERT INTO user_library (user_id, game_id, purchase_date, hours_played) VALUES
(1, 1, '2023-06-01 14:00:00', 80.5),
(1, 3, '2024-01-20 09:00:00', 25.0),
(2, 1, '2023-05-21 11:00:00', 120.0),
(2, 2, '2022-12-01 20:00:00', 250.2);

INSERT INTO reviews (user_id, game_id, rating, review_text, post_date) VALUES
(1, 1, 5, 'Amazing graphics and story! A must-play sci-fi RPG.', '2023-07-10 22:00:00'),
(2, 2, 5, 'I have lost hundreds of hours to this game. The world is massive.', '2023-03-05 19:30:00');

INSERT INTO achievements (user_id, game_id, achievement_name, description, unlock_timestamp) VALUES
(1, 1, 'First Hack', 'Successfully complete the hacking tutorial.', '2023-06-01 15:30:00'),
(3, 1, 'Chrome Justice', 'Defeat the first major boss.', '2023-06-15 14:00:00'),
(2, 2, 'Slay a Dragon', 'Defeat your first dragon in the wild.', '2023-01-20 18:00:00');

-- ### Triggers, Functions, and Procedures ###

DELIMITER $$
CREATE TRIGGER prevent_review_if_not_owned
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM user_library WHERE user_id = NEW.user_id AND game_id = NEW.game_id) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot review a game you do not own.';
    END IF;
END$$
DELIMITER ;
