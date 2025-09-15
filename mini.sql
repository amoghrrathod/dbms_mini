drop database if exists gamestoredb;
create database gamestoredb;
use gamestoredb;

create table users (
    user_id int auto_increment primary key,
    user_name varchar(100) not null,
    email varchar(255) not null unique,
    password varchar(255) not null,
    dob date,
    index (user_name)
);

create table user_address (
    address_id int auto_increment primary key,
    user_id int not null,
    address_lines text,
    pincode varchar(20),
    foreign key (user_id) references users(user_id) on delete cascade
);

create table friendships (
    user_id1 int not null,
    user_id2 int not null,
    added_date datetime default current_timestamp,
    primary key (user_id1, user_id2),
    foreign key (user_id1) references users(user_id) on delete cascade,
    foreign key (user_id2) references users(user_id) on delete cascade,
    check (user_id1 < user_id2 )
);

create table publishers (
    publisher_id int auto_increment primary key,
    publisher_name varchar(150) not null unique,
    country varchar(100)
);

create table developers (
    dev_id int auto_increment primary key,
    studio varchar(150) not null,
    country varchar(100)
);

create table tags (
    tag_id int auto_increment primary key,
    tag_name varchar(50) not null unique,
    parent_tag_id int,
    foreign key (parent_tag_id) references tags(tag_id) on delete set null
);

create table games (
    game_id int auto_increment primary key,
    game_name varchar(255) not null,
    description text,
    release_date date,
    price decimal(10, 2),
    age_rating varchar(10),
    publisher_id int,
    dev_id int,
    foreign key (publisher_id) references publishers(publisher_id) on delete set null,
    foreign key (dev_id) references developers(dev_id) on delete set null,
    index (game_name)
);

create table game_tags (
    game_id int not null,
    tag_id int not null,
    primary key (game_id, tag_id),
    foreign key (game_id) references games(game_id) on delete cascade,
    foreign key (tag_id) references tags(tag_id) on delete cascade
);

create table user_library (
    user_id int not null,
    game_id int not null,
    purchase_date datetime,
    hours_played decimal(10, 1) default 0.0,
    primary key (user_id, game_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (game_id) references games(game_id) on delete cascade
);

create table reviews (
    review_id int auto_increment primary key,
    user_id int,
    game_id int not null,
    rating int not null,
    check (rating >= 0 and rating <= 5),
    review_text text,
    post_date datetime default current_timestamp,
    foreign key (user_id) references users(user_id) on delete set null,
    foreign key (game_id) references games(game_id) on delete cascade,
    check (rating >= 1 and rating <= 5)
);

create table achievements (
    achievement_id int auto_increment primary key,
    game_id int not null,
    achievement_name varchar(255) not null,
    description text,
    foreign key (game_id) references games(game_id) on delete cascade
);

create table user_achievements (
    user_id int not null,
    achievement_id int not null,
    unlock_timestamp datetime not null,
    primary key (user_id, achievement_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (achievement_id) references achievements(achievement_id) on delete cascade
);

create table items (
    item_id int auto_increment primary key,
    game_id int not null,
    item_name varchar(150) not null,
    description text,
    foreign key (game_id) references games(game_id) on delete cascade
);

create table item_instances (
    instance_id int auto_increment primary key,
    item_id int not null,
    user_id int,
    date_acquired datetime not null,
    foreign key (item_id) references items(item_id) on delete cascade,
    foreign key (user_id) references users(user_id) on delete set null
);

insert into users (user_name, email, password, dob) values
('alice', 'alice@email.com', 'hashed_pw_1', '1995-04-12'),
('bob', 'bob@email.com', 'hashed_pw_2', '1998-07-22'),
('charlie', 'charlie@email.com', 'hashed_pw_3', '1992-11-30'),
('diana', 'diana@email.com', 'hashed_pw_4', '2001-01-15');

insert into user_address (user_id, address_lines, pincode) values
(1, '123 Pixel Street, Tech City', '560001'),
(3, '456 Quest Road, Fantasy Ville', '560025');

insert into publishers (publisher_name, country) values
('pixelpush inc.', 'usa'),
('gigagames', 'japan'),
('indiedream co.', 'canada');

insert into developers (studio, country) values
('starlight studios', 'usa'),
('codewizards', 'uk'),
('lone wolf dev', 'canada');

INSERT INTO tags (tag_name, parent_tag_id) VALUES
('RPG', NULL),
('Action', NULL),
('Sci-Fi', NULL),
('Puzzle', NULL),
('Open World', NULL),
('Strategy', NULL),
('Simulation', NULL),
('Action RPG', 1),
('JRPG', 1),
('Tactical RPG', 1),
('MMORPG', 1),
('Platformer', 2),
('Shooter', 2),
('Fighting', 2),
('Hack and Slash', 2),
('Real-Time Strategy (RTS)', 6),
('Turn-Based Strategy (TBS)', 6),
('Grand Strategy', 6),
('Tower Defense', 6),
('Vehicle Simulation', 7),
('Life Simulation', 7),
('Construction & Management', 7),
('First-Person Shooter (FPS)', 13),
('Third-Person Shooter (TPS)', 13),
('MOBA', 17),
('4X', 18),
('Flight Sim', 21),
('Racing Sim', 21);

insert into games (game_name, description, release_date, price, age_rating, publisher_id, dev_id) values
('cybernetic dawn', 'a thrilling sci-fi action rpg.', '2023-05-20', 59.99, '18+', 1, 1),
('kingdoms of ether', 'a vast open-world fantasy rpg.', '2022-11-10', 49.99, '16+', 1, 2),
('puzzle sphere', 'a relaxing and challenging puzzle game.', '2024-01-15', 19.99, '3+', 3, 3),
('galactic marauder', 'a fast-paced space strategy game.', '2023-08-01', 39.99, '12+', 2, 1);

insert into friendships (user_id1, user_id2, added_date) values
(1, 2, '2024-03-01 10:00:00'),
(1, 3, '2024-04-15 12:30:00'),
(2, 4, '2024-05-20 18:00:00');

insert into game_tags (game_id, tag_id) values
(1, 2), (1, 3), (1, 1),
(2, 1), (2, 5),
(3, 4),
(4, 3), (4, 6);

insert into user_library (user_id, game_id, purchase_date, hours_played) values
(1, 1, '2023-06-01 14:00:00', 80.5),
(1, 3, '2024-01-20 09:00:00', 25.0),
(2, 1, '2023-05-21 11:00:00', 120.0),
(2, 2, '2022-12-01 20:00:00', 250.2),
(3, 1, '2023-05-20 00:01:00', 95.5),
(3, 2, '2023-01-10 17:00:00', 150.0),
(3, 4, '2023-08-15 13:00:00', 60.0),
(4, 3, '2024-02-14 10:00:00', 15.5);

insert into reviews (user_id, game_id, rating, review_text, post_date) values
(1, 1, 5, 'amazing graphics and story! a must-play sci-fi rpg.', '2023-07-10 22:00:00'),
(2, 2, 5, 'i have lost hundreds of hours to this game. the world is massive.', '2023-03-05 19:30:00'),
(4, 3, 4, 'really clever puzzles, great for a chill evening.', '2024-03-01 16:45:00');

insert into achievements (game_id, achievement_name, description) values
(1, 'first hack', 'successfully complete the hacking tutorial.'),
(1, 'chrome justice', 'defeat the first major boss.'),
(2, 'slay a dragon', 'defeat your first dragon in the wild.'),
(2, 'master enchanter', 'craft a legendary enchanted item.');

insert into user_achievements (user_id, achievement_id, unlock_timestamp) values
(1, 1, '2023-06-01 15:30:00'),
(2, 3, '2023-01-20 18:00:00'),
(2, 4, '2023-04-10 21:15:00'),
(3, 1, '2023-05-20 01:00:00'),
(3, 2, '2023-06-15 14:00:00');

insert into items (game_id, item_name, description) values
(1, 'plasma rifle', 'standard issue energy weapon.'),
(1, 'stealth cloak', 'allows for temporary invisibility.'),
(2, 'elven sword', 'a finely crafted blade from the silver woods.'),
(2, 'health potion', 'restores a moderate amount of health.');

insert into item_instances (item_id, user_id, date_acquired) values
(1, 1, '2023-06-05 12:00:00'),
(3, 2, '2023-02-11 11:30:00'),
(4, 2, '2023-02-11 11:32:00'),
(2, 3, '2023-07-01 19:00:00');
