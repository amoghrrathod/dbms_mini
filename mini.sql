DROP DATABASE IF EXISTS gamestoredb;
CREATE DATABASE gamestoredb;
USE gamestoredb;

CREATE TABLE users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
user_name VARCHAR (100) NOT NULL,
email VARCHAR (255) NOT NULL UNIQUE,
password VARCHAR (255) NOT NULL,
dob DATE,
INDEX (user_name)
) ;

CREATE TABLE user_address (
address_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
address_lines TEXT,
pincode VARCHAR (20),
FOREIGN KEY (user_id)
REFERENCES users (user_id)
ON DELETE CASCADE
) ;

CREATE TABLE friendships (
user_id1 INT NOT NULL,
user_id2 INT NOT NULL,
added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (user_id1, user_id2),
FOREIGN KEY (user_id1)
REFERENCES users (user_id)
ON DELETE CASCADE,
FOREIGN KEY (user_id2)
REFERENCES users (user_id)
ON DELETE CASCADE,
CHECK (user_id1 < user_id2)
) ;

CREATE TABLE publishers (
publisher_id INT AUTO_INCREMENT PRIMARY KEY,
publisher_name VARCHAR (150) NOT NULL UNIQUE,
country VARCHAR (100)
) ;

CREATE TABLE developers (
dev_id INT AUTO_INCREMENT PRIMARY KEY,
studio VARCHAR (150) NOT NULL,
country VARCHAR (100)
) ;

CREATE TABLE tags (
tag_id INT AUTO_INCREMENT PRIMARY KEY,
tag_name VARCHAR (50) NOT NULL UNIQUE,
parent_tag_id INT,
FOREIGN KEY (parent_tag_id)
REFERENCES tags (tag_id)
ON DELETE SET NULL
) ;

CREATE TABLE games (
game_id INT AUTO_INCREMENT PRIMARY KEY,
game_name VARCHAR (255) NOT NULL,
description TEXT,
release_date DATE,
price DECIMAL (10, 2),
age_rating VARCHAR (10),
publisher_id INT,
dev_id INT,
FOREIGN KEY (publisher_id)
REFERENCES publishers (publisher_id)
ON DELETE SET NULL,
FOREIGN KEY (dev_id)
REFERENCES developers (dev_id)
ON DELETE SET NULL,
INDEX (game_name)
) ;

CREATE TABLE has_tags (
game_id INT NOT NULL,
tag_id INT NOT NULL,
PRIMARY KEY (game_id, tag_id),
FOREIGN KEY (game_id)
REFERENCES games (game_id)
ON DELETE CASCADE,
FOREIGN KEY (tag_id)
REFERENCES tags (tag_id)
ON DELETE CASCADE
) ;

CREATE TABLE user_library (
user_id INT NOT NULL,
game_id INT NOT NULL,
purchase_date DATETIME,
hours_played DECIMAL (10, 1) DEFAULT 0.0,
PRIMARY KEY (user_id, game_id),
FOREIGN KEY (user_id)
REFERENCES users (user_id)
ON DELETE CASCADE,
FOREIGN KEY (game_id)
REFERENCES games (game_id)
ON DELETE CASCADE
) ;

CREATE TABLE reviews (
review_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT,
game_id INT NOT NULL,
rating INT NOT NULL,
review_text TEXT,
post_date DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id)
REFERENCES users (user_id)
ON DELETE SET NULL,
FOREIGN KEY (game_id)
REFERENCES games (game_id)
ON DELETE CASCADE,
CHECK (rating >= 1 AND rating <= 5)
) ;

CREATE TABLE game_achievements (
achievement_id INT AUTO_INCREMENT PRIMARY KEY,
game_id INT NOT NULL,
achievement_name VARCHAR (255) NOT NULL,
description TEXT,
FOREIGN KEY (game_id)
REFERENCES games (game_id)
ON DELETE CASCADE
) ;

CREATE TABLE unlocked_achievements (
unlocked_achievement_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
achievement_id INT NOT NULL,
unlock_timestamp DATETIME NOT NULL,
FOREIGN KEY (user_id)
REFERENCES users (user_id)
ON DELETE CASCADE,
FOREIGN KEY (achievement_id)
REFERENCES game_achievements (achievement_id)
ON DELETE CASCADE
) ;

CREATE TABLE items (
item_id INT AUTO_INCREMENT PRIMARY KEY,
game_id INT NOT NULL,
item_name VARCHAR (150) NOT NULL,
description TEXT,
FOREIGN KEY (game_id)
REFERENCES games (game_id)
ON DELETE CASCADE
) ;

CREATE TABLE item_instances (
instance_id INT AUTO_INCREMENT PRIMARY KEY,
item_id INT NOT NULL,
user_id INT,
date_acquired DATETIME NOT NULL,
FOREIGN KEY (item_id)
REFERENCES items (item_id)
ON DELETE CASCADE,
FOREIGN KEY (user_id)
REFERENCES users (user_id)
ON DELETE SET NULL
) ;


INSERT INTO users (user_name, email, password, dob) VALUES
('alice', 'alice@email.com', 'password1', '1995-04-12'),
('bob', 'bob@email.com', 'password2', '1998-07-22'),
('charlie', 'charlie@email.com', 'password3', '1992-11-30'),
('diana', 'diana@email.com', 'password4', '2001-01-15'),
('eva', 'eva@email.com', 'password5', '1999-02-20'),
('frank', 'frank@email.com', 'password6', '1994-09-05'),
('grace', 'grace@email.com', 'password7', '2003-06-10'),
('henry', 'henry@email.com', 'password8', '1991-12-25') ;

INSERT INTO user_address (user_id, address_lines, pincode) VALUES
(1, '123 Pixel Street, Tech City', '560001'),
(3, '456 Quest Road, Fantasy Ville', '560025'),
(2, '789 Console Avenue, Gamer''s Point', '560095'),
(5, '101 VR Vista, Innovation Hub', '560066'),
(8, '212 Retro Lane, Nostalgia Town', '560038') ;

INSERT INTO publishers (publisher_name, country) VALUES
('PixelPush Inc.', 'USA'), ('GigaGames', 'Japan'), ('IndieDream Co.', 'Canada'),
('Quantum Leap Studios',
'USA'),
('Nebula Interactive',
'UK'),
('Dragonfly Games',
'China'),
('Vortex Creations',
'Germany'),
('Mirage Entertainment',
'France'),
('Crimson Peak',
'South Korea'),
('Evergreen Gaming', 'Sweden') ;

INSERT INTO developers (studio, country) VALUES
('Starlight Studios',
'USA'),
('CodeWizards',
'UK'),
('Lone Wolf Dev',
'Canada'),
('Celestial Forge',
'USA'),
('PixelHeart',
'Japan'),
('Clockwork Giants',
'Germany'),
('Ghost-Ware', 'Sweden'), ('Red Moon Studios', 'Poland'), ('Blue-shift', 'USA'),
('Dream-weavers', 'France') ;

INSERT INTO tags (tag_name, parent_tag_id) VALUES
('RPG',
NULL),
('Action',
NULL),
('Sci-Fi',
NULL),
('Puzzle',
NULL),
('Open World',
NULL),
('Strategy',
NULL),
('Simulation',
NULL),
('Action RPG',
1),
('JRPG',
1),
('Tactical RPG',
1),
('MMORPG',
1),
('Platformer',
2),
('Shooter',
2),
('Fighting',
2),
('Hack and Slash',
2),
('Real-Time Strategy (RTS)',
6),
('Turn-Based Strategy (TBS)',
6),
('Grand Strategy',
6),
('Tower Defense',
6),
('Vehicle Simulation',
7),
('Life Simulation',
7),
('Construction & Management',
7),
('First-Person Shooter (FPS)',
13),
('Third-Person Shooter (TPS)',
13),
('MOBA',
17),
('4X', 18), ('Flight Sim', 21), ('Racing Sim', 21) ;

INSERT INTO games (game_name,
description,
release_date,
price,
age_rating,
publisher_id,
dev_id) VALUES
('Cybernetic Dawn',
'A thrilling sci-fi action RPG.',
'2023-05-20',
59.99,
'18+',
1,
1),
('Kingdoms of Ether',
'A vast open-world fantasy RPG.',
'2022-11-10',
49.99,
'16+',
1,
2),
('Puzzle Sphere',
'A relaxing and challenging puzzle game.',
'2024-01-15',
19.99,
'3+',
3,
3),
('Galactic Marauder',
'A fast-paced space strategy game.',
'2023-08-01',
39.99,
'12+',
2,
1),
('Project Chimera',
'A tactical RPG set in a dystopian future.',
'2023-09-12',
45.00,
'16+',
4,
4),
('Stardust Odyssey',
'An epic JRPG adventure across the cosmos.',
'2022-07-21',
55.00,
'12+',
5,
5),
('City Builders Deluxe',
'The ultimate construction and management simulation.',
'2023-02-28',
39.99,
'3+',
6,
6),
('Phantom Signal',
'A stealth-action game with a gripping narrative.',
'2024-03-19',
49.99,
'18+',
7,
7),
('The Last Spell',
'A turn-based strategy game with rogue-lite elements.',
'2023-03-09',
24.99,
'16+',
8,
8),
('AstroShift',
'A mind-bending puzzle-platformer.',
'2022-10-05',
15.00,
'7+',
9,
9),
('World at War: 1944',
'A grand strategy game set in World War II.',
'2023-11-11',
35.00,
'12+',
10,
10),
('Neon Riders',
'A fast-paced cyberpunk racing game.',
'2024-04-25',
29.99,
'12+',
1,
4),
('Dragon''s Breath',
'An open-world fantasy MMORPG.',
'2023-01-10',
0.00,
'16+',
2,
5),
('Cosmic Drift',
'A space combat simulation with realistic physics.',
'2022-12-01',
40.00,
'7+',
3,
6),
('The Forgotten City',
'A mystery adventure game with a time loop mechanic.',
'2021-07-28',
29.99,
'16+',
4,
7),
('Shattered Realms',
'A dark fantasy action RPG.',
'2024-05-30',
59.99,
'18+',
5,
8),
('Dungeon Masters',
'A co-op hack and slash game.',
'2023-06-15',
19.99,
'16+',
6,
9),
('Starship Tycoon',
'A business simulation game in space.',
'2022-09-01',
25.00,
'3+',
7,
10),
('The Crimson Curse', 'A gothic horror RPG.', '2023-10-31', 49.99, '18+', 8, 1),
('Cyber Heist',
'A stealth game with a focus on hacking.',
'2024-02-14',
39.99,
'16+',
9,
2),
('Age of Sail: Empires',
'A naval strategy game.',
'2022-08-18',
34.99,
'12+',
10,
3),
('The Last Stand: Aftermath',
'A zombie survival rogue-lite.',
'2021-11-16',
24.99,
'18+',
1,
4),
('Project Warlock 2',
'A retro-style first-person shooter.',
'2022-06-10',
19.99,
'18+',
2,
5),
('The Wandering Village',
'A city-building simulation game on the back of a giant creature.',
'2022-09-14',
24.99,
'12+',
3,
6),
('Gloomwood',
'A stealth horror FPS that lets you play your way.',
'2022-08-16',
19.99,
'18+',
4,
7),
('Tunic',
'An isometric action-adventure game about a small fox on a big adventure.',
'2022-03-16',
29.99,
'7+',
5,
8),
('Stray',
'A third-person cat adventure game set amidst the detailed, neon-lit alleys of a decaying cybercity.',
'2022-07-19',
29.99,
'12+',
6,
9),
('V Rising', 'A vampire survival game.', '2022-05-17', 19.99, '16+', 7, 10),
('Warhammer 40,000: Boltgun',
'A retro-style first-person shooter set in the Warhammer 40,000 universe.',
'2023-05-23',
21.99,
'18+',
8,
1),
('Dredge',
'A single-player fishing adventure with a sinister undercurrent.',
'2023-03-30',
24.99,
'12+',
9,
2) ;

INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(1, 'First Hack', 'Successfully complete the hacking tutorial.'),
(1, 'Chrome Justice', 'Defeat the first major boss.'),
(1, 'De-commissioned', 'Defeat the first boss.'),
(1, 'Cyber ninja', 'Complete the game using only melee weapons.'),
(1, 'Millionaire', 'Amass 1,000,000 credits.'),
(2, 'Slay a Dragon', 'Defeat your first dragon in the wild.'),
(2, 'Master Enchanter', 'Craft a legendary enchanted item.'),
(2, 'King of the Castle', 'Fully upgrade your stronghold.'),
(2, 'Master Alchemist', 'Brew every type of potion.'),
(3, 'Novice Puzzler', 'Complete the first 10 levels.'),
(3, 'Speed Runner', 'Complete a level in under 30 seconds.'),
(4, 'First Blood', 'Win your first battle.'),
(4, 'Conqueror', 'Conquer an entire galaxy.'),
(5, 'Mission Accomplished', 'Complete the first mission.'),
(5, 'No Casualties', 'Complete a mission without any of your units dying.'),
(6, 'The Journey Begins', 'Start your adventure.'),
(6, 'Savior of the Cosmos', 'Defeat the final boss.'),
(7, 'My First City', 'Build your first city.'),
(7, 'Metropolis', 'Reach a population of 1,000,000.'),
(8, 'Ghost', 'Complete a level without being detected.'),
(8,
'Silent Assassin',
'Eliminate all enemies in a level without being detected.'),
(9,
'Critical Efficiency',
'Inflict a critical hit on 20 enemies in one Hero''s turn.'),
(9, 'All At Once', 'Have a Hero or building hit 12 enemies in a single blow.'),
(10, 'First Shift', 'Complete the first level.'),
(10, 'Quantum Leap', 'Shift through 100 dimensions.'),
(11, 'D-Day', 'Successfully land your troops in Normandy.'),
(11, 'Operation Barbarossa', 'Invade the Soviet Union.'),
(12, 'First Race', 'Complete your first race.'),
(12, 'Champion', 'Win the championship.'),
(13, 'Dragon''s Bane', 'Slay the great dragon.'),
(13, 'Master Crafter', 'Craft a legendary item.'),
(14, 'First Kill', 'Destroy your first enemy ship.'),
(14, 'Ace Pilot', 'Achieve 100 kills.'),
(15, 'Looper', 'Loop through time once.'),
(15, 'Super Looper', 'Loop through time ten times.'),
(16, 'Realm Walker', 'Travel to all the realms.'),
(16, 'Demon Slayer', 'Slay 1000 demons.'),
(17, 'Dungeon Crawler', 'Complete 10 dungeons.'),
(17, 'Boss Slayer', 'Defeat all the bosses.'),
(18, 'First Ship', 'Build your first starship.'),
(18, 'Millionaire', 'Earn your first million credits.'),
(19, 'Vampire Hunter', 'Kill your first vampire.'),
(19, 'Curse Breaker', 'Break the crimson curse.'),
(20, 'First Heist', 'Complete your first heist.'),
(20, 'Ghost in the Machine', 'Complete a heist without being detected.'),
(21, 'First Command', 'Take command of your first ship.'),
(21, 'Master and Commander', 'Win a battle against a superior enemy.'),
(22, 'The Beginning of The End', 'Complete the tutorial.'),
(22, 'A Death in the Aftermath', 'Kill a Volunteer.'),
(23, 'The woods are calling.', 'Travel through the ancient forest.'),
(23, 'Fallen ruins.', 'Reach the ruin complex.'),
(24, 'Petting Zoo', 'Pet Onbu.'),
(24, 'Fore!', 'Feed Onbu with the Feeding Trebuchet.'),
(25, 'The Doctor is in', 'Meet the Doctor.'),
(25, 'Out of the Fog', 'Escape the fog.'),
(26, 'A Stick!', 'Found a stick.'),
(26, 'A Sword!', 'Found a sword.'),
(27, 'A Little Chatty', 'Meow 100 times.'),
(27, 'Cat-a-Pult', 'Jump 500 times.'),
(28, 'A First Taste', 'Drink the blood of a living creature.'),
(28, 'First of Many', 'Drink the blood of a V Blood carrier.'),
(29, 'Chapter I - Complete', 'Complete all Chapter I Missions.'),
(29, 'Chapter II - Complete', 'Complete all Chapter II Missions.'),
(30, 'Introductions', 'Complete the introduction quest.'),
(30, 'The Key', 'Deliver the Key.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(1, 'Plasma Rifle', 'Standard issue energy weapon.'),
(1, 'Stealth Cloak', 'Allows for temporary invisibility.'),
(1, 'Katana', 'A high-frequency blade.'),
(1, 'Railgun', 'A powerful long-range weapon.'),
(1, 'Cyberdeck', 'Allows for hacking of terminals and enemies.'),
(2, 'Elven Sword', 'A finely crafted blade from the Silver Woods.'),
(2, 'Health Potion', 'Restores a moderate amount of health.'),
(2, 'Dragonbone Sword', 'A powerful sword crafted from dragon bones.'),
(2, 'Elixir of Life', 'A potion that fully restores health and mana.'),
(3, 'Hint Coin', 'Reveals a hint for a puzzle.'),
(3, 'Time Freeze', 'Temporarily stops the timer.'),
(4, 'Dreadnought', 'The most powerful class of starship.'),
(4, 'Planet Cracker', 'A weapon capable of destroying planets.'),
(5,
'Exosuit',
'A powered suit of armor that enhances strength and durability.'),
(5, 'Gauss Rifle', 'A powerful rifle that fires projectiles at high velocity.'),
(6, 'Stardust Blade', 'A sword forged from a fallen star.'),
(6, 'Phoenix Down', 'Revives a fallen party member.'),
(7, 'Skyscraper', 'A very tall building.'),
(7, 'Nuclear Power Plant', 'A power plant that generates a lot of energy.'),
(8, 'Silenced Pistol', 'A pistol with a silencer.'),
(8, 'Tranquilizer Darts', 'Darts that put enemies to sleep.'),
(9, 'Knife', 'A simple one-handed melee weapon.'),
(9, 'Axe', 'A one-handed melee weapon with good damage.'),
(10, 'Dimension Shifter', 'The device used to shift between dimensions.'),
(10, 'Gravity Boots', 'Allows the player to walk on walls and ceilings.'),
(11, 'Infantry Division', 'A division of infantry soldiers.'),
(11, 'Panzer Division', 'A division of German tanks.'),
(12, 'Nitro Boost', 'Provides a temporary speed boost.'),
(12, 'EMP Mine', 'Disables nearby vehicles.'),
(13, 'Dragon Scale Armor', 'Armor crafted from the scales of a dragon.'),
(13, 'Phoenix Blade', 'A sword that can be reborn from its ashes.'),
(14, 'Laser Cannon', 'A basic energy weapon.'),
(14, 'Proton Torpedo', 'A powerful explosive weapon.'),
(15, 'Bow', 'A ranged weapon.'),
(15, 'Flashlight', 'Provides light in dark areas.'),
(16, 'Soul Reaver', 'A sword that steals the souls of its victims.'),
(16, 'Demon Hide Armor', 'Armor made from the hide of a demon.'),
(17, 'Holy Avenger', 'A sword that is holy in nature.'),
(17, 'Plate of the Dragon', 'Armor that is made from the scales of a dragon.'),
(18, 'Freighter', 'A large ship used for transporting cargo.'),
(18, 'Cruise Liner', 'A luxurious ship for transporting passengers.'),
(19, 'Silver Sword', 'A sword made of silver, effective against vampires.'),
(19, 'Holy Water', 'Water that has been blessed, effective against vampires.'),
(20, 'Icepick', 'A tool for breaking into computer systems.'),
(20, 'Firewall Breaker', 'A program for breaking through firewalls.'),
(21, 'Sloop', 'A small and fast sailing ship.'),
(21, 'Frigate', 'A medium-sized warship.'),
(22, 'Bandages', 'Used to stop bleeding and heal wounds.'),
(22, 'Medkit', 'A medical kit for treating injuries.'),
(23, 'Revolver', 'A trusty sidearm.'),
(23, 'Pump Action Shotgun', 'A powerful close-range weapon.'),
(24, 'Berry', 'A type of food that can be gathered.'),
(24, 'Mushroom', 'A type of food that can be grown.'),
(25, 'Cane Sword', 'A sword hidden in a cane.'),
(25, 'Revolver', 'A firearm.'),
(26, 'Stick', 'A simple melee weapon.'),
(26, 'Sword', 'A powerful melee weapon.'),
(27, 'B-12 Memory', 'A collectible that unlocks memories.'),
(27, 'Badge', 'A collectible that appears on the cat''s backpack.'),
(28, 'Sword', 'A melee weapon.'),
(28, 'Axe', 'A tool for chopping wood and a melee weapon.'),
(29, 'Chainsword', 'A melee weapon.'),
(29, 'Boltgun', 'The iconic weapon of a Space Marine.'),
(30, 'Old Iron Chain', 'A valuable trinket.'),
(30, 'Broken Monocle', 'A valuable trinket.') ;

INSERT INTO friendships (user_id1, user_id2, added_date) VALUES
(1, 2, '2024-03-01 10:00:00'),
(1, 3, '2024-04-15 12:30:00'),
(2, 4, '2024-05-20 18:00:00'),
(1, 4, '2024-06-01 11:00:00'),
(2, 3, '2024-06-05 14:00:00'),
(3, 5, '2024-06-10 09:30:00'),
(4, 6, '2024-07-11 18:45:00'),
(5, 7, '2024-07-20 20:00:00'),
(6, 8, '2024-08-01 12:00:00'),
(7, 8, '2024-08-02 15:30:00') ;

INSERT INTO has_tags (game_id, tag_id) VALUES
(1, 2), (1, 3), (1, 1),
(2, 1), (2, 5),
(3, 4),
(4, 3), (4, 6),
(5, 10), (5, 3),
(6, 9), (6, 3),
(7, 22), (7, 7),
(8, 2),
(9, 17),
(10, 4), (10, 12),
(11, 18),
(12, 28), (12, 3),
(13, 11), (13, 5),
(14, 27), (14, 3),
(15, 4), (15, 2),
(16, 8),
(17, 15), (17, 1),
(18, 7), (18, 22),
(19, 1),
(20, 2), (20, 3),
(21, 6),
(22, 2), (22, 13),
(23, 23),
(24, 7), (24, 6),
(25, 23), (25, 2),
(26, 8), (26, 4),
(27, 4), (27, 12),
(28, 5), (28, 1),
(29, 23),
(30, 4), (30, 7) ;

INSERT INTO user_library (user_id, game_id, purchase_date, hours_played) VALUES
(1, 1, '2023-06-01 14:00:00', 80.5),
(1, 3, '2024-01-20 09:00:00', 25.0),
(2, 1, '2023-05-21 11:00:00', 120.0),
(2, 2, '2022-12-01 20:00:00', 250.2),
(3, 1, '2023-05-20 00:01:00', 95.5),
(3, 2, '2023-01-10 17:00:00', 150.0),
(3, 4, '2023-08-15 13:00:00', 60.0),
(4, 3, '2024-02-14 10:00:00', 15.5),
(5, 10, '2023-01-01 10:00:00', 10.5),
(5, 15, '2023-02-10 12:30:00', 25.0),
(6, 20, '2023-03-15 18:00:00', 5.0),
(6, 25, '2023-04-20 20:00:00', 15.2),
(7, 5, '2023-05-25 14:00:00', 30.0),
(7, 12, '2023-06-30 16:30:00', 40.5),
(8, 8, '2023-07-01 11:00:00', 50.0),
(8, 18, '2023-08-10 13:00:00', 22.0),
(1, 5, '2023-09-15 10:00:00', 45.5),
(1, 26, '2022-04-01 18:30:00', 33.0),
(2, 27, '2022-08-01 12:00:00', 15.0),
(2, 28, '2022-06-10 21:00:00', 180.5),
(2, 30, '2023-04-05 11:45:00', 40.0),
(3, 29, '2023-05-25 10:00:00', 25.5),
(3, 9, '2023-03-10 13:20:00', 75.0),
(3, 17, '2023-07-01 19:00:00', 55.8),
(4, 27, '2022-07-20 15:00:00', 12.5),
(4, 24, '2022-10-01 16:00:00', 65.0),
(4, 7, '2023-03-02 12:30:00', 90.3),
(5, 6, '2022-08-11 14:10:00', 110.0),
(5, 23, '2022-06-15 17:00:00', 38.5),
(5, 13, '2023-01-11 08:00:00', 300.0),
(6, 11, '2023-11-12 20:30:00', 88.0),
(6, 21, '2022-09-01 11:00:00', 120.7),
(6, 16, '2024-06-02 14:00:00', 22.0),
(7, 2, '2023-01-01 18:00:00', 45.0),
(7, 22, '2022-01-15 19:30:00', 60.5),
(7, 30, '2023-04-01 22:00:00', 28.0),
(8, 1, '2023-06-10 16:45:00', 70.0),
(8, 14, '2023-02-15 10:15:00', 95.2),
(8, 25, '2022-08-20 18:00:00', 44.0) ;

INSERT INTO reviews (user_id, game_id, rating, review_text, post_date) VALUES
(1,
1,
5,
'Amazing graphics and story! A must-play sci-fi RPG.',
'2023-07-10 22:00:00'),
(2,
2,
5,
'I have lost hundreds of hours to this game. The world is massive.',
'2023-03-05 19:30:00'),
(4,
3,
4,
'Really clever puzzles, great for a chill evening.',
'2024-03-01 16:45:00'),
(5,
10,
4,
'AstroShift is a mind-bending puzzle-platformer 
that will keep you hooked for hours.',
'2023-01-15 14:00:00'),
(6,
20,
5,
'Cyber Heist is a thrilling stealth game 
with a focus on hacking. Highly recommended!',
'2023-03-20 19:30:00'),
(7,
5,
3,
'Project Chimera is a decent 
tactical RPG, but it can be a bit repetitive at times.',
'2023-06-01 16:45:00'),
(8,
8,
5,
'Phantom Signal is a masterpiece of stealth-action. 
The story is gripping and the gameplay is flawless.',
'2023-07-10 22:00:00'),
(1,
5,
4,
'Challenging and rewarding tactical gameplay. The story is a bit generic though.',
'2023-10-01 11:00:00'),
(2,
28,
5,
'Absolutely addictive. Building a castle and hunting for blood is an amazing loop.',
'2022-08-15 16:20:00'),
(3,
9,
5,
'One of the best strategy games in years. Incredibly difficult but fair.',
'2023-05-18 09:00:00'),
(4,
27,
5,
'Playing as a cat is as fun as it sounds. A beautiful, short and sweet adventure.',
'2022-08-05 14:50:00'),
(5,
6,
4,
'Classic JRPG feel with a modern twist. The space exploration theme is fantastic.',
'2022-09-30 21:00:00'),
(6,
11,
4,
'Deep and complex grand strategy. A must for history buffs, but has a steep learning curve.',
'2024-01-10 12:15:00'),
(7,
30,
5,
'Cozy fishing game with a cosmic horror twist. Did not expect to love it this much.',
'2023-05-01 19:00:00'),
(8,
1,
4,
'Solid action RPG. The world feels alive and the combat is punchy.',
'2023-08-11 23:00:00'),
(2,
30,
4,
'A surprisingly tense and atmospheric game. Highly recommended.',
'2023-04-25 10:00:00'),
(3,
29,
5,
'Pure, unadulterated retro shooter fun. Perfectly captures the 40k vibe.',
'2023-06-15 17:30:00'),
(5,
13,
3,
'Fun MMO, but very grindy at the endgame. Great with friends.',
'2023-04-10 13:00:00'),
(7,
2,
4,
'A huge world to explore with tons of content. 
Can feel a bit overwhelming at times.',
'2023-02-20 18:25:00') ;

INSERT INTO unlocked_achievements (user_id,
achievement_id,
unlock_timestamp) VALUES
(1, 1, '2023-06-01 15:30:00'),
(3, 1, '2023-05-20 01:00:00'),
(3, 2, '2023-06-15 14:00:00'),
(2, 6, '2023-01-20 18:00:00'),
(2, 7, '2023-04-10 21:15:00'),
(1, 14, '2023-09-20 15:00:00'),
(2, 63, '2022-05-20 18:00:00'),
(2, 64, '2022-05-22 19:10:00'),
(3, 21, '2023-03-12 14:30:00'),
(3, 61, '2023-05-26 11:00:00'),
(4, 59, '2022-07-20 15:30:00'),
(5, 16, '2022-07-25 10:00:00'),
(6, 25, '2023-11-13 09:15:00'),
(7, 65, '2023-04-02 12:00:00'),
(8, 19, '2023-07-05 20:45:00'),
(1, 57, '2022-04-03 19:00:00'),
(1, 58, '2022-04-03 19:30:00') ;

INSERT INTO item_instances (item_id, user_id, date_acquired) VALUES
(1, 1, '2023-06-05 12:00:00'),
(6, 2, '2023-02-11 11:30:00'),
(7, 2, '2023-02-11 11:32:00'),
(2, 3, '2023-07-01 19:00:00'),
(14, 1, '2023-09-18 11:20:00'),
(59, 2, '2022-05-25 14:00:00'),
(60, 2, '2022-05-25 14:05:00'),
(23, 3, '2023-03-11 18:00:00'),
(57, 4, '2022-07-21 16:00:00'),
(16, 5, '2022-08-01 10:30:00'),
(17, 5, '2022-08-01 10:32:00'),
(28, 6, '2023-11-15 13:00:00'),
(63, 7, '2023-04-10 21:00:00'),
(20, 8, '2023-07-03 22:15:00'),
(21, 8, '2023-07-03 22:18:00') ;


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
