drop database if exists gamestoredb;
create database gamestoredb;
use gamestoredb;

create table users (
user_id int auto_increment primary key,
user_name varchar (100) not null,
email varchar (255) not null unique,
password varchar (255) not null,
dob date,
index (user_name)
) ;

create table user_address (
address_id int auto_increment primary key,
user_id int not null,
address_lines text,
pincode varchar (20),
foreign key (user_id) references users (user_id) on delete cascade
) ;

create table friendships (
user_id1 int not null,
user_id2 int not null,
added_date datetime default current_timestamp,
primary key (user_id1, user_id2),
foreign key (user_id1) references users (user_id) on delete cascade,
foreign key (user_id2) references users (user_id) on delete cascade,
check (user_id1 < user_id2)
) ;

create table publishers (
publisher_id int auto_increment primary key,
publisher_name varchar (150) not null unique,
country varchar (100)
) ;

create table developers (
dev_id int auto_increment primary key,
studio varchar (150) not null,
country varchar (100)
) ;

create table tags (
tag_id int auto_increment primary key,
tag_name varchar (50) not null unique,
parent_tag_id int,
foreign key (parent_tag_id) references tags (tag_id) on delete set null
) ;

create table games (
game_id int auto_increment primary key,
game_name varchar (255) not null,
description text,
release_date date,
price decimal (10, 2),
age_rating varchar (10),
publisher_id int,
dev_id int,
foreign key (publisher_id) references publishers (publisher_id) on delete set null,
foreign key (dev_id) references developers (dev_id) on delete set null,
index (game_name)
) ;

create table has_tags (
game_id int not null,
tag_id int not null,
primary key (game_id, tag_id),
foreign key (game_id) references games (game_id) on delete cascade,
foreign key (tag_id) references tags (tag_id) on delete cascade
) ;

create table user_library (
user_id int not null,
game_id int not null,
purchase_date datetime,
hours_played decimal (10, 1) default 0.0,
primary key (user_id, game_id),
foreign key (user_id) references users (user_id) on delete cascade,
foreign key (game_id) references games (game_id) on delete cascade
) ;

create table reviews (
review_id int auto_increment primary key,
user_id int,
game_id int not null,
rating int not null,
check (rating > = 0 and rating < = 5),
review_text text,
post_date datetime default current_timestamp,
foreign key (user_id) references users (user_id) on delete set null,
foreign key (game_id) references games (game_id) on delete cascade,
check (rating > = 1 and rating < = 5)
) ;

create table game_achievements (
achievement_id int auto_increment primary key,
game_id int not null,
achievement_name varchar (255) not null,
description text,
foreign key (game_id) references games (game_id) on delete cascade
) ;

create table unlocked_achievements (
unlocked_achievement_id int auto_increment primary key,
user_id int not null,
achievement_id int not null,
unlock_timestamp datetime not null,
foreign key (user_id) references users (user_id) on delete cascade,
foreign key (achievement_id) references game_achievements (achievement_id) on delete cascade
) ;

create table items (
item_id int auto_increment primary key,
game_id int not null,
item_name varchar (150) not null,
description text,
foreign key (game_id) references games (game_id) on delete cascade
) ;

create table item_instances (
instance_id int auto_increment primary key,
item_id int not null,
user_id int,
date_acquired datetime not null,
foreign key (item_id) references items (item_id) on delete cascade,
foreign key (user_id) references users (user_id) on delete set null
) ;

insert into users (user_name, email, password, dob) values
('alice', 'alice@email.com', 'password1', '1995-04-12'),
('bob', 'bob@email.com', 'password2', '1998-07-22'),
('charlie', 'charlie@email.com', 'password3', '1992-11-30'),
('diana', 'diana@email.com', 'password4', '2001-01-15') ;

-- Add more users
INSERT INTO users (user_name, email, password, dob) VALUES
('eva', 'eva@email.com', 'password5', '1999-02-20'),
('frank', 'frank@email.com', 'password6', '1994-09-05'),
('grace', 'grace@email.com', 'password7', '2003-06-10'),
('henry', 'henry@email.com', 'password8', '1991-12-25') ;

-- Add more games to the user library
INSERT INTO user_library (user_id, game_id, purchase_date, hours_played) VALUES
(5, 10, '2023-01-01 10:00:00', 10.5),
(5, 15, '2023-02-10 12:30:00', 25.0),
(6, 20, '2023-03-15 18:00:00', 5.0),
(6, 25, '2023-04-20 20:00:00', 15.2),
(7, 5, '2023-05-25 14:00:00', 30.0),
(7, 12, '2023-06-30 16:30:00', 40.5),
(8, 8, '2023-07-01 11:00:00', 50.0),
(8, 18, '2023-08-10 13:00:00', 22.0) ;

-- Add more reviews
INSERT INTO reviews (user_id, game_id, rating, review_text, post_date) VALUES
(5,
10,
4,
'AstroShift is a mind-bending puzzle-platformer that will keep you hooked for hours.',
'2023-01-15 14:00:00'),
(6,
20,
5,
'Cyber Heist is a thrilling stealth game with a focus on hacking. Highly recommended!',
'2023-03-20 19:30:00'),
(7,
5,
3,
'Project Chimera is a decent tactical RPG, but it can be a bit repetitive at times.',
'2023-06-01 16:45:00'),
(8,
8,
5,
'Phantom Signal is a masterpiece of stealth-action. The story is gripping and the gameplay is flawless.',
'2023-07-10 22:00:00') ;
insert into user_address (user_id, address_lines, pincode) values
(1, '123 Pixel Street, Tech City', '560001'),
(3, '456 Quest Road, Fantasy Ville', '560025') ;

insert into publishers (publisher_name, country) values
('PixelPush Inc.', 'USA'),
('GigaGames', 'Japan'),
('IndieDream Co.', 'Canada'),
('Quantum Leap Studios', 'USA'),
('Nebula Interactive', 'UK'),
('Dragonfly Games', 'China'),
('Vortex Creations', 'Germany'),
('Mirage Entertainment', 'France'),
('Crimson Peak', 'South Korea'),
('Evergreen Gaming', 'Sweden') ;

insert into developers (studio, country) values
('Starlight Studios', 'USA'),
('CodeWizards', 'UK'),
('Lone Wolf Dev', 'Canada'),
('Celestial Forge', 'USA'),
('PixelHeart', 'Japan'),
('Clockwork Giants', 'Germany'),
('Ghost-Ware', 'Sweden'),
('Red Moon Studios', 'Poland'),
('Blue-shift', 'USA'),
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
('4X',
18),
('Flight Sim',
21),
('Racing Sim',
21) ;

insert into games (game_name,
description,
release_date,
price,
age_rating,
publisher_id,
dev_id) values
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

insert into friendships (user_id1, user_id2, added_date) values
(1, 2, '2024-03-01 10:00:00'),
(1, 3, '2024-04-15 12:30:00'),
(2, 4, '2024-05-20 18:00:00') ;

insert into has_tags (game_id, tag_id) values
(1, 2), (1, 3), (1, 1),
(2, 1), (2, 5),
(3, 4),
(4, 3), (4, 6) ;

insert into user_library (user_id, game_id, purchase_date, hours_played) values
(1, 1, '2023-06-01 14:00:00', 80.5),
(1, 3, '2024-01-20 09:00:00', 25.0),
(2, 1, '2023-05-21 11:00:00', 120.0),
(2, 2, '2022-12-01 20:00:00', 250.2),
(3, 1, '2023-05-20 00:01:00', 95.5),
(3, 2, '2023-01-10 17:00:00', 150.0),
(3, 4, '2023-08-15 13:00:00', 60.0),
(4, 3, '2024-02-14 10:00:00', 15.5) ;

insert into reviews (user_id, game_id, rating, review_text, post_date) values
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
'2024-03-01 16:45:00') ;

insert into game_achievements (game_id, achievement_name, description) values
(1, 'First Hack', 'Successfully complete the hacking tutorial.'),
(1, 'Chrome Justice', 'Defeat the first major boss.'),
(2, 'Slay a Dragon', 'Defeat your first dragon in the wild.'),
(2, 'Master Enchanter', 'Craft a legendary enchanted item.') ;

insert into unlocked_achievements (user_id,
achievement_id,
unlock_timestamp) values
(1, 1, '2023-06-01 15:30:00'),
(3, 1, '2023-05-20 01:00:00'),
(3, 2, '2023-06-15 14:00:00'),
(2, 3, '2023-01-20 18:00:00'),
(2, 4, '2023-04-10 21:15:00') ;

insert into items (game_id, item_name, description) values
(1, 'Plasma Rifle', 'Standard issue energy weapon.'),
(1, 'Stealth Cloak', 'Allows for temporary invisibility.'),
(2, 'Elven Sword', 'A finely crafted blade from the Silver Woods.'),
(2, 'Health Potion', 'Restores a moderate amount of health.') ;

insert into item_instances (item_id, user_id, date_acquired) values
(1, 1, '2023-06-05 12:00:00'),
(3, 2, '2023-02-11 11:30:00'),
(4, 2, '2023-02-11 11:32:00'),
(2, 3, '2023-07-01 19:00:00') ;

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
-- Achievements and Items for the first 10 games

-- Cybernetic Dawn (game_id = 1) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(1, 'De-commissioned', 'Defeat the first boss.'),
(1, 'Cyber ninja', 'Complete the game using only melee weapons.'),
(1, 'Millionaire', 'Amass 1,000,000 credits.'),
(1, 'Fully Loaded', 'Fully upgrade a legendary weapon.'),
(1, 'Explorer', 'Visit every sector in the game.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(1, 'Katana', 'A high-frequency blade.'),
(1, 'Railgun', 'A powerful long-range weapon.'),
(1, 'Cyberdeck', 'Allows for hacking of terminals and enemies.'),
(1, 'Adrenaline Booster', 'Temporarily increases speed and damage.'),
(1, 'Chameleon Cloak', 'Provides temporary invisibility.') ;

-- Kingdoms of Ether (game_id = 2) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(2, 'Dragon Slayer', 'Defeat the ancient dragon.'),
(2, 'King of the Castle', 'Fully upgrade your stronghold.'),
(2, 'Master Alchemist', 'Brew every type of potion.'),
(2, 'A-Lister', 'Reach maximum reputation with all factions.'),
(2, 'The Wanderer', 'Discover all hidden locations.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(2, 'Dragonbone Sword', 'A powerful sword crafted from dragon bones.'),
(2, 'Elixir of Life', 'A potion that fully restores health and mana.'),
(2, 'Staff of the Archmage', 'A staff that greatly enhances magical power.'),
(2, 'Shadow-weave Armor', 'Armor that provides stealth bonuses.'),
(2, 'Amulet of Kings', 'An amulet that increases all stats.') ;

-- Puzzle Sphere (game_id = 3) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(3, 'Novice Puzzler', 'Complete the first 10 levels.'),
(3, 'Speed Runner', 'Complete a level in under 30 seconds.'),
(3, 'Perfectionist', 'Get 3 stars on every level.'),
(3, 'Mind Bender', 'Complete a puzzle without using any hints.'),
(3, 'Puzzle Master', 'Complete the game.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(3, 'Hint Coin', 'Reveals a hint for a puzzle.'),
(3, 'Time Freeze', 'Temporarily stops the timer.'),
(3, 'Extra Life', 'Provides an extra life.'),
(3, 'Color Bomb', 'Clears all spheres of a certain color.'),
(3, 'Wild Card', 'Can be matched with any color.') ;

-- Galactic Marauder (game_id = 4) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(4, 'First Blood', 'Win your first battle.'),
(4, 'Conqueror', 'Conquer an entire galaxy.'),
(4, 'Economist', 'Amass 1,000,000,000 resources.'),
(4, 'Technocrat', 'Research all technologies.'),
(4, 'Legendary Commander', 'Win 100 battles.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(4, 'Dreadnought', 'The most powerful class of starship.'),
(4, 'Planet Cracker', 'A weapon capable of destroying planets.'),
(4, 'Cloaking Device', 'Renders a fleet invisible.'),
(4, 'Hyperspace Drive', 'Allows for faster-than-light travel.'),
(4, 'Stargate', 'Allows for instantaneous travel between two points.') ;

-- Project Chimera (game_id = 5) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(5, 'Mission Accomplished', 'Complete the first mission.'),
(5, 'No Casualties', 'Complete a mission without any of your units dying.'),
(5, 'Iron Man', 'Complete the game on the hardest difficulty.'),
(5, 'Squad Goals', 'Fully upgrade all your squad members.'),
(5, 'Master Tactician', 'Win a battle without taking any damage.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(5,
'Exosuit',
'A powered suit of armor that enhances strength and durability.'),
(5, 'Gauss Rifle', 'A powerful rifle that fires projectiles at high velocity.'),
(5, 'Medkit', 'Heals a unit''s injuries.'),
(5, 'Stealth Camo', 'Provides temporary invisibility.'),
(5, 'Combat Drone', 'A drone that can be deployed to assist in battle.') ;

-- Stardust Odyssey (game_id = 6) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(6, 'The Journey Begins', 'Start your adventure.'),
(6, 'Savior of the Cosmos', 'Defeat the final boss.'),
(6, 'Ultimate Weapon', 'Obtain the legendary weapon.'),
(6, 'Best Friends', 'Reach maximum friendship level with all party members.'),
(6, 'Collector', 'Collect all rare items.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(6, 'Stardust Blade', 'A sword forged from a fallen star.'),
(6, 'Phoenix Down', 'Revives a fallen party member.'),
(6, 'Megalixir', 'Fully restores the party''s health and mana.'),
(6, 'Summon Materia', 'Allows the user to summon powerful beings.'),
(6, 'Airship', 'A flying ship that can be used to travel the world.') ;

-- City Builders Deluxe (game_id = 7) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(7, 'My First City', 'Build your first city.'),
(7, 'Metropolis', 'Reach a population of 1,000,000.'),
(7, 'Green City', 'Have a city with no pollution.'),
(7, 'Tycoon', 'Have a treasury of 1,000,000,000.'),
(7, 'Architectural Marvel', 'Build all the landmarks.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(7, 'Skyscraper', 'A very tall building.'),
(7, 'Nuclear Power Plant', 'A power plant that generates a lot of energy.'),
(7, 'Space Elevator', 'A tower that connects the ground to outer space.'),
(7, 'Fusion Power Plant', 'A clean and efficient power source.'),
(7, 'Arcology', 'A self-contained, futuristic city.') ;

-- Phantom Signal (game_id = 8) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(8, 'Ghost', 'Complete a level without being detected.'),
(8,
'Silent Assassin',
'Eliminate all enemies in a level without being detected.'),
(8, 'Pacifist', 'Complete a level without killing anyone.'),
(8, 'Master of Disguise', 'Use every disguise in the game.'),
(8, 'True Phantom', 'Complete the game without being detected.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(8, 'Silenced Pistol', 'A pistol with a silencer.'),
(8, 'Tranquilizer Darts', 'Darts that put enemies to sleep.'),
(8, 'Lockpick', 'Used to open locked doors.'),
(8, 'Smoke Bomb', 'Creates a cloud of smoke to obscure vision.'),
(8, 'Night Vision Goggles', 'Allows for vision in the dark.') ;

-- The Last Spell (game_id = 9) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(9,
'Critical Efficiency',
'Inflict a critical hit on 20 enemies in one Hero''s turn.'),
(9, 'All At Once', 'Have a Hero or building hit 12 enemies in a single blow.'),
(9, 'Divide and Conquer', 'Have a Hero kill 200 isolated enemies in one run.'),
(9,
'Sadist Fantasy',
'Kill 300 enemies affected by negative alterations in one run.'),
(9, 'Punch Out', 'Kill an enemy with the Punch skill.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(9, 'Knife', 'A simple one-handed melee weapon.'),
(9, 'Axe', 'A one-handed melee weapon with good damage.'),
(9, 'Wand', 'A basic magic weapon.'),
(9, 'Shortbow', 'A ranged weapon with a decent fire rate.'),
(9, 'Pistol', 'A one-handed ranged weapon.') ;

-- AstroShift (game_id = 10) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(10, 'First Shift', 'Complete the first level.'),
(10, 'Quantum Leap', 'Shift through 100 dimensions.'),
(10, 'Collector', 'Find all the hidden collectibles.'),
(10, 'Time Traveler', 'Complete a level in record time.'),
(10, 'Master of Dimensions', 'Complete the game.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(10, 'Dimension Shifter', 'The device used to shift between dimensions.'),
(10, 'Gravity Boots', 'Allows the player to walk on walls and ceilings.'),
(10, 'Time Rewinder', 'Rewinds time by a few seconds.'),
(10, 'Jetpack', 'Allows for temporary flight.'),
(10, 'Energy Shield', 'Protects the player from damage.') ;
-- Achievements and Items for games 11-20

-- World at War: 1944 (game_id = 11) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(11, 'D-Day', 'Successfully land your troops in Normandy.'),
(11, 'Operation Barbarossa', 'Invade the Soviet Union.'),
(11, 'Fall of Berlin', 'Conquer the German capital.'),
(11, 'Master Strategist', 'Win the war without losing a single battle.'),
(11, 'Victorious', 'Win the war.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(11, 'Infantry Division', 'A division of infantry soldiers.'),
(11, 'Panzer Division', 'A division of German tanks.'),
(11, 'Fighter Squadron', 'A squadron of fighter planes.'),
(11, 'Bomber Squadron', 'A squadron of bomber planes.'),
(11, 'Battleship', 'A powerful naval warship.') ;

-- Neon Riders (game_id = 12) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(12, 'First Race', 'Complete your first race.'),
(12, 'Champion', 'Win the championship.'),
(12, 'Fully Upgraded', 'Fully upgrade your vehicle.'),
(12, 'Untouchable', 'Win a race without taking any damage.'),
(12, 'Street Legend', 'Become a legend of the streets.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(12, 'Nitro Boost', 'Provides a temporary speed boost.'),
(12, 'EMP Mine', 'Disables nearby vehicles.'),
(12, 'Plasma Shield', 'Protects your vehicle from damage.'),
(12, 'Mag-Lev Wheels', 'Allows your vehicle to hover.'),
(12, 'AI Co-pilot', 'Assists with driving and combat.') ;

-- Dragon's Breath (game_id = 13) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(13, 'Dragon''s Bane', 'Slay the great dragon.'),
(13, 'Master Crafter', 'Craft a legendary item.'),
(13, 'Guild Leader', 'Become the leader of a guild.'),
(13, 'World Explorer', 'Discover all regions of the world.'),
(13, 'Legendary Hero', 'Reach the maximum level.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(13, 'Dragon Scale Armor', 'Armor crafted from the scales of a dragon.'),
(13, 'Phoenix Blade', 'A sword that can be reborn from its ashes.'),
(13, 'Staff of the Lich King', 'A powerful staff that can raise the dead.'),
(13, 'Elixir of Immortality', 'A potion that grants eternal life.'),
(13, 'Flying Mount', 'A creature that can be ridden to fly through the air.') ;

-- Cosmic Drift (game_id = 14) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(14, 'First Kill', 'Destroy your first enemy ship.'),
(14, 'Ace Pilot', 'Achieve 100 kills.'),
(14, 'Capital Ship Killer', 'Destroy a capital ship.'),
(14, 'Fleet Commander', 'Command a fleet of 10 ships.'),
(14, 'Galactic Hero', 'Save the galaxy from the alien threat.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(14, 'Laser Cannon', 'A basic energy weapon.'),
(14, 'Proton Torpedo', 'A powerful explosive weapon.'),
(14, 'Shield Generator', 'Generates a protective energy shield.'),
(14, 'Afterburner', 'Provides a temporary speed boost.'),
(14, 'Warp Drive', 'Allows for faster-than-light travel.') ;

-- The Forgotten City (game_id = 15) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(15, 'Looper', 'Loop through time once.'),
(15, 'Super Looper', 'Loop through time ten times.'),
(15, 'The Many Shall Suffer', 'Reach Ending 1 of 4.'),
(15, 'The One That Got Away', 'Reach Ending 2 of 4.'),
(15, 'The Canon Ending', 'Reach Ending 4 of 4.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(15, 'Bow', 'A ranged weapon.'),
(15, 'Flashlight', 'Provides light in dark areas.'),
(15, 'Pistol', 'A ranged weapon.'),
(15, 'Zip Line', 'Allows for fast travel between two points.'),
(15, 'Immaculate Dwarven Boots', 'A pair of well-crafted boots.') ;

-- Shattered Realms (game_id = 16) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(16, 'Realm Walker', 'Travel to all the realms.'),
(16, 'Demon Slayer', 'Slay 1000 demons.'),
(16, 'Lord of the Abyss', 'Defeat the final boss.'),
(16, 'Master of Magic', 'Learn all the spells.'),
(16, 'The Unbroken', 'Complete the game without dying.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(16, 'Soul Reaver', 'A sword that steals the souls of its victims.'),
(16, 'Demon Hide Armor', 'Armor made from the hide of a demon.'),
(16, 'Void Crystal', 'A crystal that can be used to cast powerful magic.'),
(16, 'Potion of Berserking', 'A potion that sends the user into a rage.'),
(16, 'Ring of Power', 'A ring that grants the wearer immense power.') ;

-- Dungeon Masters (game_id = 17) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(17, 'Dungeon Crawler', 'Complete 10 dungeons.'),
(17, 'Boss Slayer', 'Defeat all the bosses.'),
(17, 'Treasure Hunter', 'Find all the hidden treasures.'),
(17,
'Legendary Party',
'Complete the game with a full party of legendary heroes.'),
(17, 'Master of the Dungeon', 'Complete the game on the hardest difficulty.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(17, 'Holy Avenger', 'A sword that is holy in nature.'),
(17, 'Plate of the Dragon', 'Armor that is made from the scales of a dragon.'),
(17, 'Ring of Regeneration', 'A ring that regenerates the wearer''s health.'),
(17,
'Potion of Giant Strength',
'A potion that grants the user the strength of a giant.'),
(17, 'Tome of Knowledge', 'A book that grants the reader knowledge.') ;

-- Starship Tycoon (game_id = 18) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(18, 'First Ship', 'Build your first starship.'),
(18, 'Millionaire', 'Earn your first million credits.'),
(18, 'Galactic Magnate', 'Become the richest person in the galaxy.'),
(18, 'Master of Trade', 'Control all the trade routes.'),
(18, 'CEO of the Galaxy', 'Own the largest corporation in the galaxy.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(18, 'Freighter', 'A large ship used for transporting cargo.'),
(18, 'Cruise Liner', 'A luxurious ship for transporting passengers.'),
(18, 'Asteroid Miner', 'A ship used for mining asteroids.'),
(18, 'Trade Route License', 'A license to operate on a specific trade route.'),
(18, 'Corporate Headquarters', 'The headquarters of your corporation.') ;

-- The Crimson Curse (game_id = 19) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(19, 'Vampire Hunter', 'Kill your first vampire.'),
(19, 'Curse Breaker', 'Break the crimson curse.'),
(19, 'Lord of the Night', 'Become a vampire lord.'),
(19, 'Master of the Occult', 'Learn all the occult secrets.'),
(19, 'Survivor', 'Survive the night.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(19, 'Silver Sword', 'A sword made of silver, effective against vampires.'),
(19, 'Holy Water', 'Water that has been blessed, effective against vampires.'),
(19, 'Wooden Stake', 'A wooden stake, effective against vampires.'),
(19, 'Tome of Exorcism', 'A book that contains the rites of exorcism.'),
(19, 'Garlic', 'A bulb of garlic, effective at repelling vampires.') ;

-- Cyber Heist (game_id = 20) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(20, 'First Heist', 'Complete your first heist.'),
(20, 'Ghost in the Machine', 'Complete a heist without being detected.'),
(20, 'Master Hacker', 'Hack into the most secure system in the world.'),
(20, 'Untraceable', 'Cover your tracks perfectly.'),
(20, 'Legendary Thief', 'Become the most famous thief in the world.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(20, 'Icepick', 'A tool for breaking into computer systems.'),
(20, 'Firewall Breaker', 'A program for breaking through firewalls.'),
(20, 'Data Scrambler', 'A program for scrambling data.'),
(20,
'Cloaking Software',
'A program that makes you invisible to security systems.'),
(20, 'Botnet', 'A network of computers that can be used to launch attacks.') ;
-- Achievements and Items for games 21-30

-- Age of Sail: Empires (game_id = 21) - Fictional
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(21, 'First Command', 'Take command of your first ship.'),
(21, 'Master and Commander', 'Win a battle against a superior enemy.'),
(21, 'Trafalgar', 'Win a decisive naval battle.'),
(21, 'Circumnavigation', 'Sail around the world.'),
(21, 'Lord of the Seas', 'Control all major trade routes.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(21, 'Sloop', 'A small and fast sailing ship.'),
(21, 'Frigate', 'A medium-sized warship.'),
(21, 'Man-o''War', 'A large and powerful warship.'),
(21,
'Letter of Marque',
'A government license authorizing a privateer to attack and capture enemy vessels.'),
(21, 'Treasure Map', 'A map that leads to buried treasure.') ;

-- The Last Stand: Aftermath (game_id = 22) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(22, 'The Beginning of The End', 'Complete the tutorial.'),
(22, 'A Death in the Aftermath', 'Kill a Volunteer.'),
(22, 'For Whom the Bell Tolls', 'Kill 10 Volunteers.'),
(22, 'Genomic Anomaly', 'Acquire a mutation.'),
(22, 'Tinkerer', 'Craft an item at a crafting station.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(22, 'Bandages', 'Used to stop bleeding and heal wounds.'),
(22, 'Medkit', 'A medical kit for treating injuries.'),
(22, 'Molotov Cocktail', 'A crude incendiary weapon.'),
(22, 'Pipe Bomb', 'A homemade explosive device.'),
(22, 'Baseball Bat', 'A blunt melee weapon.') ;

-- Project Warlock 2 (game_id = 23) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(23, 'The woods are calling.', 'Travel through the ancient forest.'),
(23, 'Fallen ruins.', 'Reach the ruin complex.'),
(23, 'Necromancer''s playground.', 'Fight through the ruins.'),
(23, 'The wolf''s den.', 'Defeat the Necromancer.'),
(23, 'Headshot newbie', 'Kill 100 monsters with headshots.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(23, 'Revolver', 'A trusty sidearm.'),
(23, 'Pump Action Shotgun', 'A powerful close-range weapon.'),
(23, 'SMG', 'A fast-firing submachine gun.'),
(23, 'Rifle', 'A long-range weapon.'),
(23, 'Cannon', 'A heavy weapon that fires explosive projectiles.') ;

-- The Wandering Village (game_id = 24) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(24, 'Petting Zoo', 'Pet Onbu.'),
(24, 'Fore!', 'Feed Onbu with the Feeding Trebuchet.'),
(24, 'Berry Good', 'Achieve 100% efficiency with a Berry Gatherer.'),
(24, 'Doki Doki Waku Waku', 'Get Onbu''s heart rate to go above 6 bpm.'),
(24, 'Full Body Shave', 'Cut down every tree on Onbu''s back.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(24, 'Berry', 'A type of food that can be gathered.'),
(24, 'Mushroom', 'A type of food that can be grown.'),
(24, 'Wood', 'A basic building material.'),
(24, 'Stone', 'A basic building material.'),
(24, 'Water', 'A vital resource for your villagers.') ;

-- Gloomwood (game_id = 25) - Early Access
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(25, 'The Doctor is in', 'Meet the Doctor.'),
(25, 'Out of the Fog', 'Escape the fog.'),
(25, 'Amnesia', 'Forget who you are.'),
(25, 'Master Thief', 'Steal everything.'),
(25, 'The Gloom', 'Embrace the gloom.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(25, 'Cane Sword', 'A sword hidden in a cane.'),
(25, 'Revolver', 'A firearm.'),
(25, 'Shotgun', 'A powerful firearm.'),
(25, 'Lantern', 'A source of light.'),
(25, 'Lockpick', 'A tool for opening locks.') ;

-- Tunic (game_id = 26) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(26, 'A Stick!', 'Found a stick.'),
(26, 'A Sword!', 'Found a sword.'),
(26, 'What just happened?', 'Was resurrected.'),
(26, 'You hear a strange hum.', 'Engaged a strange device.'),
(26, 'Your gift is accepted.', 'Made an offering.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(26, 'Stick', 'A simple melee weapon.'),
(26, 'Sword', 'A powerful melee weapon.'),
(26, 'Shield', 'Used for blocking attacks.'),
(26, 'Lantern', 'Illuminates dark areas.'),
(26, 'Magic Potion', 'Replenishes health.') ;

-- Stray (game_id = 27) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(27, 'A Little Chatty', 'Meow 100 times.'),
(27, 'Cat-a-Pult', 'Jump 500 times.'),
(27, 'Productive Day', 'Sleep for more than one hour.'),
(27, 'Boom Chat Kalaka', 'Dunk the basketball.'),
(27, 'No More Lives', 'Die 9 times.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(27, 'B-12 Memory', 'A collectible that unlocks memories.'),
(27, 'Badge', 'A collectible that appears on the cat''s backpack.'),
(27, 'Sheet Music', 'A collectible that can be given to a musician.'),
(27, 'Energy Drink', 'A collectible that can be traded.'),
(27, 'Outsider Notebook', 'A crucial item for story progression.') ;

-- V Rising (game_id = 28) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(28, 'A First Taste', 'Drink the blood of a living creature.'),
(28, 'First of Many', 'Drink the blood of a V Blood carrier.'),
(28,
'Lord of the Land',
'Place a Castle Heart and claim an unoccupied territory.'),
(28, 'Larger Pockets!', 'Equip a bag.'),
(28, 'Upon a Pale Horse', 'Ride a horse.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(28, 'Sword', 'A melee weapon.'),
(28, 'Axe', 'A tool for chopping wood and a melee weapon.'),
(28, 'Mace', 'A blunt melee weapon.'),
(28, 'Spear', 'A polearm melee weapon.'),
(28, 'Crossbow', 'A ranged weapon.') ;

-- Warhammer 40,000: Boltgun (game_id = 29) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(29, 'Chapter I - Complete', 'Complete all Chapter I Missions.'),
(29, 'Chapter II - Complete', 'Complete all Chapter II Missions.'),
(29, 'Chapter III - Complete', 'Complete all Chapter III Missions.'),
(29, 'Defeat a Lord of Change', 'Defeat a Lord of Change.'),
(29, 'Defeat a Great Unclean One', 'Defeat a Great Unclean One.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(29, 'Chainsword', 'A melee weapon.'),
(29, 'Boltgun', 'The iconic weapon of a Space Marine.'),
(29, 'Shotgun', 'A close-range weapon.'),
(29, 'Plasma Gun', 'An energy weapon.'),
(29, 'Heavy Bolter', 'A heavy version of the Boltgun.') ;

-- Dredge (game_id = 30) - Real
INSERT INTO game_achievements (game_id, achievement_name, description) VALUES
(30, 'Introductions', 'Complete the introduction quest.'),
(30, 'The Key', 'Deliver the Key.'),
(30, 'The Secret', 'Surrender the Music Box.'),
(30, 'The Bond', 'Entrust the Ring.'),
(30, 'The Chains', 'Relinquish the Necklace.') ;

INSERT INTO items (game_id, item_name, description) VALUES
(30, 'Old Iron Chain', 'A valuable trinket.'),
(30, 'Broken Monocle', 'A valuable trinket.'),
(30, 'Worn Gold Ring', 'A valuable trinket.'),
(30, 'Doubloon', 'A valuable coin.'),
(30, 'Engine', 'Improves the boat''s speed.') ;
