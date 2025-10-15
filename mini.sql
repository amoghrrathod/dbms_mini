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

-- Corrected Achievement Tables
CREATE TABLE game_achievements (
    achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    achievement_name VARCHAR(255) NOT NULL,
    description TEXT,
    FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE
);

CREATE TABLE unlocked_achievements (
    unlocked_achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    unlock_timestamp DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES game_achievements (achievement_id) ON DELETE CASCADE
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
('diana', 'diana@email.com', 'password101', '2001-01-15');

INSERT INTO user_address (user_id, address_lines, pincode) VALUES
(1, '123 Pixel Street, Tech City', '560001'),
(3, '456 Quest Road, Fantasy Ville', '560025');

INSERT INTO publishers (publisher_name, country) VALUES
('PixelPush Inc.', 'USA'), ('GigaGames', 'Japan'), ('IndieDream Co.', 'Canada'),
('Quantum Leap Studios', 'USA'), ('Nebula Interactive', 'UK'), ('Dragonfly Games', 'China'),
('Vortex Creations', 'Germany'), ('Mirage Entertainment', 'France'), ('Crimson Peak', 'South Korea'),
('Evergreen Gaming', 'Sweden');

INSERT INTO developers (studio, country) VALUES
('Starlight Studios', 'USA'), ('CodeWizards', 'UK'), ('Lone Wolf Dev', 'Canada'),
('Celestial Forge', 'USA'), ('PixelHeart', 'Japan'), ('Clockwork Giants', 'Germany'),
('Ghost-Ware', 'Sweden'), ('Red Moon Studios', 'Poland'), ('Blue-shift', 'USA'),
('Dream-weavers', 'France');

INSERT INTO tags (tag_name, parent_tag_id) VALUES
('RPG', NULL), ('Action', NULL), ('Sci-Fi', NULL), ('Puzzle', NULL), ('Open World', NULL),
('Strategy', NULL), ('Simulation', NULL), ('Action RPG', 1), ('JRPG', 1), ('Tactical RPG', 1),
('MMORPG', 1), ('Platformer', 2), ('Shooter', 2), ('Fighting', 2), ('Hack and Slash', 2),
('Real-Time Strategy (RTS)', 6), ('Turn-Based Strategy (TBS)', 6), ('Grand Strategy', 6),
('Tower Defense', 6), ('Vehicle Simulation', 7), ('Life Simulation', 7), ('Construction & Management', 7),
('First-Person Shooter (FPS)', 13), ('Third-Person Shooter (TPS)', 13), ('MOBA', 16),
('4X', 17), ('Flight Sim', 20), ('Racing Sim', 20);

INSERT INTO games (game_name, description, release_date, price, age_rating, publisher_id, dev_id) VALUES
('Cybernetic Dawn', 'A thrilling sci-fi action RPG.', '2023-05-20', 59.99, '18+', 1, 1),
('Kingdoms of Ether', 'A vast open-world fantasy RPG.', '2022-11-10', 49.99, '16+', 1, 2),
('Puzzle Sphere', 'A relaxing and challenging puzzle game.', '2024-01-15', 19.99, '3+', 3, 3),
('Galactic Marauder', 'A fast-paced space strategy game.', '2023-08-01', 39.99, '12+', 2, 1),
('Project Chimera', 'A tactical RPG set in a dystopian future.', '2023-09-12', 45.00, '16+', 4, 4),
('Stardust Odyssey', 'An epic JRPG adventure across the cosmos.', '2022-07-21', 55.00, '12+', 5, 5),
('City Builders Deluxe', 'The ultimate construction and management simulation.', '2023-02-28', 39.99, '3+', 6, 6),
('Phantom Signal', 'A stealth-action game with a gripping narrative.', '2024-03-19', 49.99, '18+', 7, 7),
('The Last Spell', 'A turn-based strategy game with rogue-lite elements.', '2023-03-09', 24.99, '16+', 8, 8),
('AstroShift', 'A mind-bending puzzle-platformer.', '2022-10-05', 15.00, '7+', 9, 9),
('World at War: 1944', 'A grand strategy game set in World War II.', '2023-11-11', 35.00, '12+', 10, 10),
('Neon Riders', 'A fast-paced cyberpunk racing game.', '2024-04-25', 29.99, '12+', 1, 4),
('Baldur''s Gate 3', 'A story-rich, party-based RPG set in the universe of Dungeons & Dragons.', '2023-08-03', 59.99, '18+', 5, 8),
('Elden Ring', 'An action RPG from FromSoftware.', '2022-02-25', 59.99, '18+', 6, 9),
('Cyberpunk 2077', 'An open-world, action-adventure story from CD PROJEKT RED.', '2020-12-10', 59.99, '18+', 7, 10),
('The Witcher 3: Wild Hunt', 'A story-driven, open-world RPG from CD PROJEKT RED.', '2015-05-19', 39.99, '18+', 8, 1);

INSERT INTO friendships (user_id1, user_id2, added_date) VALUES
(1, 2, '2024-03-01 10:00:00'),
(1, 3, '2024-04-15 12:30:00'),
(2, 4, '2024-05-20 18:00:00');

INSERT INTO has_tags (game_id, tag_id) VALUES
(1, 2), (1, 3), (1, 1),
(2, 1), (2, 5),
(3, 4),
(4, 3), (4, 6);

INSERT INTO user_library (user_id, game_id, purchase_date, hours_played) VALUES
(1, 1, '2023-06-01 14:00:00', 80.5),
(1, 3, '2024-01-20 09:00:00', 25.0),
(2, 1, '2023-05-21 11:00:00', 120.0),
(2, 2, '2022-12-01 20:00:00', 250.2),
(3, 1, '2023-05-20 00:01:00', 95.5),
(3, 2, '2023-01-10 17:00:00', 150.0),
(3, 4, '2023-08-15 13:00:00', 60.0),
(4, 3, '2024-02-14 10:00:00', 15.5);

INSERT INTO reviews (user_id, game_id, rating, review_text, post_date) VALUES
(1, 1, 5, 'Amazing graphics and story! A must-play sci-fi RPG.', '2023-07-10 22:00:00'),
(2, 2, 5, 'I have lost hundreds of hours to this game. The world is massive.', '2023-03-05 19:30:00'),
(4, 3, 4, 'Really clever puzzles, great for a chill evening.', '2024-03-01 16:45:00');

INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(1, 'First Hack', 'Successfully complete the hacking tutorial.'),
(1, 'Chrome Justice', 'Defeat the first major boss.'),
(2, 'Slay a Dragon', 'Defeat your first dragon in the wild.'),
(2, 'Master Enchanter', 'Craft a legendary enchanted item.');

INSERT INTO unlocked_achievements (user_id, achievement_id, unlock_timestamp) VALUES
(1, 1, '2023-06-01 15:30:00'),
(3, 1, '2023-05-20 01:00:00'),
(3, 2, '2023-06-15 14:00:00'),
(2, 3, '2023-01-20 18:00:00'),
(2, 4, '2023-04-10 21:15:00');

INSERT INTO items (game_id, item_name, description) VALUES
(1, 'Plasma Rifle', 'Standard issue energy weapon.'),
(1, 'Stealth Cloak', 'Allows for temporary invisibility.'),
(2, 'Elven Sword', 'A finely crafted blade from the Silver Woods.'),
(2, 'Health Potion', 'Restores a moderate amount of health.');

INSERT INTO item_instances (item_id, user_id, date_acquired) VALUES
(1, 1, '2023-06-05 12:00:00'),
(3, 2, '2023-02-11 11:30:00'),
(4, 2, '2023-02-11 11:32:00'),
(2, 3, '2023-07-01 19:00:00');

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

DELIMITER $$
CREATE FUNCTION get_average_game_rating(g_id INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    SELECT AVG(rating) INTO avg_rating FROM reviews WHERE game_id = g_id;
    RETURN avg_rating;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_games_by_tag(IN tag_name_param VARCHAR(50))
BEGIN
    SELECT g.game_id, g.game_name, g.description, g.release_date, g.price
    FROM games g
    JOIN has_tags ht ON g.game_id = ht.game_id
    JOIN tags t ON ht.tag_id = t.tag_id
    WHERE t.tag_name = tag_name_param;
END$$
DELIMITER ;
