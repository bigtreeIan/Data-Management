-- HW2
-- Yihan Xu, 47011405

-- create a user table which collect the 
-- commen information about Bird and Watcher
CREATE Table Useer(
	user_tag INTEGER NOT NULL,
    email VARCHAR(100) NOT NULL,
    pass_word INTEGER NOT NULL,
    sign_date DATETIME NOT NULL,
    addr_country VARCHAR(100) NOT NULL,
    addr_number INTEGER NOT NULL,
    addr_mailcode INTEGER NOT NULL,
    addr_street VARCHAR(100) NOT NULL,
    addr_state VARCHAR(100) NOT NULL,
    addr_city VARCHAR(100) NOT NULL,
    primary key (user_tag)
);

-- create a bird table which collect the unique attribue
-- of bird and btag as primary key.
CREATE TABLE Bird(
	bird_tag	INTEGER NOT NULL,
	income	INTEGER NOT NULL,
    birth_date	DATETIME NOT NULL,
    name_first	VARCHAR(100) NOT NULL,
    name_last	VARCHAR(100) NOT NULL,
    gender	CHAR(20) NOT NULL,
    primary key (bird_tag),
    foreign key (bird_tag) references Useer(user_tag)
    on delete cascade
);

-- peacock isa bird
CREATE TABLE Peacock(
	peacock_tag	INTEGER NOT NULL,
    primary key (peacock_tag),
    foreign key (peacock_tag) references Bird(bird_tag)
    on delete cascade
);

-- create table for multi-value attribute varity
CREATE Table Peacock_varity(
	peacock_tag	INTEGER NOT NULL,
    varity VARCHAR(100) NOT NULL,
    primary key (peacock_tag, varity),
    foreign key (peacock_tag) references Peacock(peacock_tag)
    on delete cascade -- if peacock get deleted, delete varity
);

-- create table for watcher, which is another kind of user
CREATE Table Watcher(
	watcher_tag INTEGER NOT NULL,
    fee INTEGER NOT NULL,
    business_name VARCHAR(100) NOT NULL,
    business_sector VARCHAR(100) NOT NULL,
    funding_date DATETIME NOT NULL,
    primary key (watcher_tag),
    foreign key (watcher_tag) references Useer(user_tag)
    on delete cascade
);

-- create ad table for ads
CREATE TABLE Ad(
	watcher_tag	INTEGER NOT NULL,
	adid	INTEGER NOT NULL,
    caption	VARCHAR(100) NOT NULL,
    picture VARCHAR(100) NOT NULL,
    PRIMARY KEY (adid),
    UNIQUE(caption, picture),
    FOREIGN KEY (watcher_tag) references Watcher(watcher_tag) on delete no action
);

CREATE Table Chirp(
	cno INTEGER NOT NULL,
	cno_p INTEGER NOT NULL, -- chrip parrots chrip
    tag_p INTEGER NOT NULL,
	bird_tag INTEGER NOT NULL, -- bird utter chrip 
    location_lat DECIMAL(10,6) NOT NULL,
    location_lon DECIMAL(10,6) NOT NULL,
    txt VARCHAR(100) NOT NULL,
    chrip_date DATETIME NOT NULL,
    chrip_time TIME NOT NULL,
    sentiment DECIMAL(10,10),
    primary key (cno, bird_tag), -- make chrip associate with bird
    foreign key (cno_p, tag_p) references Chirp(cno,btag),
    foreign key (bird_tag) references Bird(bird_tag)
    on delete cascade
);

CREATE Table Topic(
	topic_id	INTEGER NOT NULL,
    topic_name	VARCHAR(100) NOT NULL,
    description VARCHAR(100) NOT NULL,
    primary key (topic_id)
);

CREATE Table TopicListen(
	user_tag INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    primary key (user_tag, topic_id),
    foreign key (user_tag) references Useer(user_tag)
	on delete cascade,
    foreign key (topic_id) references Topic(topic_id)
	on delete cascade
);

CREATE Table Interests(
	interestlevel INTEGER NOT NULL,
    user_tag INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    primary key (user_tag, topic_id),
    foreign key (user_tag) references Useer(user_tag)
	on delete cascade,
    foreign key (topic_id) references Topic(topic_id)
	on delete cascade
);


CREATE Table BirdListen(
    bird_tag INTEGER NOT NULL,
    user_tag INTEGER NOT NULL,
    primary key (bird_tag, user_tag),
    foreign key (bird_tag) references Bird(bird_tag)
    on delete cascade,
    foreign key (user_tag) references Useer(user_tag)
    on delete cascade
);

CREATE Table About(
	cno INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    bird_tag INTEGER NOT NULL,
    primary key (cno, bird_tag, topic_id),
    foreign key (cno,bird_tag) references Chirp(cno,bird_tag)
    on delete cascade,
    foreign key (topic_id) references Topic(topic_id)
    on delete cascade
);