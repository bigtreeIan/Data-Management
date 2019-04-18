-- Clean-up statements to allow for repeated script testing DROP TABLE IF EXISTS BirdDevice;
DROP TABLE IF EXISTS AdShown;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS BirdCall;
-- Skeletal tables from the main TopicalBirds schema to allow testing DROP TABLE IF EXISTS Bird;
DROP TABLE IF EXISTS Ad;
DROP TABLE IF EXISTS Watcher;
CREATE TABLE Watcher(wtag VARCHAR(30) PRIMARY KEY); INSERT INTO Watcher VALUES ('9876');
CREATE TABLE Bird(btag VARCHAR(30) PRIMARY KEY); INSERT INTO Bird VALUES ('1234'), ('2341'), ('3412'); CREATE TABLE Ad(aid INTEGER PRIMARY KEY);
INSERT INTO Ad VALUES (5678), (6785), (7856); -- New tables:
-- New table for recording information about Birds' mobile devices.
-- At a particular point in time, a given device will be on a network
-- with an assigned phone number that will ring through to the device.
-- Device types are given by their manufacturer (make) and model number. -- Each device made by a manufacturer has a serial number whose
-- value will be set using a coding scheme defined by its manufacturer.
-- Certain devices (e.g., expensive ones) may be shared by several Birds.
CREATE TABLE BirdDevice( btag VARCHAR(30),
phonenum VARCHAR(20),
network VARCHAR(10),
serialno VARCHAR(40),
make VARCHAR(20),
model VARCHAR(40),
PRIMARY KEY (btag, phonenum),
UNIQUE (btag, make, serialno),
FOREIGN KEY (btag) REFERENCES Bird(btag)
);
INSERT INTO BirdDevice(btag, phonenum, network, serialno, make, model) VALUES
('1234', '(321) 456-0987', 'Verizon', 'SN1234567890', 'Samsung', 'Note 7'), ('2341', '(123) 465-9078', 'Sprint', 'XX98733', 'HTC', 'One'),
('3412', '(321) 456-0987', 'Verizon', 'SN1234567890', 'Samsung', 'Note 7');
-- New table for keeping track of when Birds are shown ads by a given watcher.
-- Used to avoid the annoyance of showing a given Bird the same ads too often.
CREATE TABLE AdShown( aid INTEGER,
wtag VARCHAR(30),
wbname VARCHAR(50),
btag VARCHAR(30),
shown_at DATETIME,
PRIMARY KEY (aid, btag, shown_at),
FOREIGN KEY (aid) REFERENCES Ad (aid), FOREIGN KEY (wtag) REFERENCES Watcher (wtag), FOREIGN KEY (btag) REFERENCES Bird (btag)
);
INSERT INTO AdShown(aid, wtag, wbname, btag, shown_at) VALUES (5678, '9876', 'Best Buy', '1234', '2017-01-26 23:10:10');
-- New table to separate addresses from Users to allow address sharing.
-- Under a new Trump executive order, designed to make it easier for DHS -- to track immigrants' locations, states must now ensure that all of their -- street names are unique throughout the entire state (or else risk losing -- federal funding). For example, only one city in New York state can have -- a street named Broadway now.
CREATE TABLE Address( loc_id BIGINT,
bldg_number VARCHAR(20), street_name VARCHAR(50), city VARCHAR(20),
state VARCHAR(20),
country VARCHAR(20),
mailcode CHAR(5), PRIMARY KEY (loc_id)
);
INSERT INTO Address(loc_id, bldg_number, street_name, city, state, country, mailcode) VALUES (1234567890, '513', 'Woodside Terrace', 'Madison', 'Wisconsin', 'USA', 53711);
-- New table added to keep track of all Bird-to-Bird phone calls.
-- Added to secure a round of venture capital funding from In-Q-Tel.
CREATE TABLE BirdCall( phone1 VARCHAR(20),
phone2 VARCHAR(20),
start_time DATETIME,
duration TIME,
PRIMARY KEY (phone1, phone2, start_time)
);
INSERT INTO BirdCall (phone1, phone2, start_time, duration)
VALUES ('(321) 456-0987', '(123) 465-9078', '2017-01-26 23:10:10', '00:06:11');