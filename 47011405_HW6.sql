/*Name: Yihan Xu
ID: 47011405
ucinetID: yihanx2*/
DROP PROCEDURE IF EXISTS NewChirp;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NewChirp`(
	new_btag VARCHAR(30),
    loc_lat DECIMAL(10,6),
    loc_long DECIMAL(10,6),
    SENTIMENT DECIMAL(2,1),
    content VARCHAR(255) 
)
BEGIN
	DECLARE new_cno INT(11);
    SET new_cno = 1 + 
					 (SELECT MAX(c.cno)
					  FROM Bird b, Chirp c
                      WHERE new_btag = c.btag);
	
    INSERT INTO Chirp(btag, 
					  cno, 
                      date,
                      location_latitude, 
                      location_longitude, 
                      parrots_btag,
                      parrots_cno,
                      sentiment,
                      text,
                      time)
   
   VALUES(new_btag, 
		  new_cno,
          CURDATE(),
          loc_lat,
          loc_long, 
		  null,
		  null,
		  SENTIMENT,
		  content,
		  CURTIME());
END $$/*1(a) (i)*/
DELIMITER ;

CALL  NewChirp ('realDonaldTrump', 0.0, 0.0, 1.0, 'Russia is our new best friend!');
SELECT  *  FROM  Chirp  WHERE  btag  LIKE  'real%'; /*1(a) (ii)*/

DROP PROCEDURE IF EXISTS ParrotChirp;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ParrotChirp`(
	new_btag VARCHAR(30),
    loc_lat DECIMAL(10,6),
    loc_long DECIMAL(10,6),
    orig_btag VARCHAR(30),
    orig_cno INT(11))
BEGIN
	DECLARE new_cno INT(11); 
	DECLARE new_sentiment DECIMAL(2,1);
	DECLARE new_text VARCHAR(255);
	SET new_cno = 1 + 
					(SELECT MAX(c.cno)
					 FROM Bird b, Chirp c
					 WHERE new_btag = c.btag);
	SET new_sentiment = (SELECT c.sentiment
						 FROM Chirp c
                         /*find the original chirper*/
                         WHERE orig_btag = c.btag and
							   orig_cno = c.cno);
                               
	SET new_text = (SELECT c.text
					FROM Chirp c
                    WHERE orig_btag = c.btag and
						  orig_cno = c.cno);
	INSERT INTO Chirp(btag, 
					  cno, 
                      date,
                      location_latitude, 
                      location_longitude, 
                      parrots_btag,
                      parrots_cno,
                      sentiment,
                      text,
                      time)
   
	VALUES(new_btag, 
		   new_cno,
	       CURDATE(),
		   loc_lat,
		   loc_long, 
		   orig_btag,
		   orig_cno,
		   new_sentiment,
		   new_text,
		   CURTIME());
END $$ /*1(b) (i)*/
DELIMITER ;

CALL ParrotChirp('swolf', 0.0, 0.0, 'realDonaldTrump', 10);
SELECT * FROM Chirp WHERE btag = 'swolf'; /*1(b) (ii)*/

-- delete fail because of foreign key constrain
DELETE IGNORE FROM Watcher 
WHERE wtag = 'burtonangel'; /*2(a)*/ 


ALTER TABLE Ad
DROP FOREIGN KEY `ad_ibfk_1`;/*2(b)*/


ALTER TABLE Ad
ADD CONSTRAINT `ad_ibfk_1`
FOREIGN KEY (wtag) 
REFERENCES Watcher(wtag) 
ON DELETE CASCADE; 

-- delete succeed because alter
DELETE IGNORE FROM Watcher 
WHERE wtag = 'burtonangel';
-- the ad is deleted too
SELECT *
FROM Ad A
WHERE A.wtag = 'burtonangel'; /*2(c)*/


DROP TRIGGER IF EXISTS Cascade_deletion_to_User;
DELIMITER $$
CREATE TRIGGER Cascade_deletion_to_User
AFTER DELETE ON Bird  
FOR EACH ROW 
BEGIN
DELETE FROM User
WHERE tag = old.btag;
END $$ /*3(a)*/
DELIMITER ;


DELETE b.*
FROM Bird b
WHERE b.btag = 'amandaclark';

-- user is also deleted
SELECT * 
FROM User u
WHERE tag = 'amandaclark'; /*3(b)*/


DROP VIEW IF EXISTS parrotstatistics;
CREATE VIEW parrotstatistics(
	btag,
    email,
    age,
    number_of_chirp,
    min_sentiment,
    max_sentiment,
    average_sentiment,
    starting_date,
    ending_date
) 
AS(
SELECT b.btag,
	   u.email,
       TIMESTAMPDIFF(YEAR, b.birthdate, CURDATE()),
	   COUNT(c.cno),
	   MIN(c.sentiment),
	   MAX(c.sentiment),
	   AVG(c.sentiment),
	   MIN(c.date),
	   MAX(c.date)
FROM Bird b
JOIN User u  ON (b.btag = u.tag)
JOIN Chirp c  ON (b.btag = c.btag)
GROUP BY b.btag); /*4(a)*/


SELECT v.btag, 
	   v.email, 
	   v.age, 
       v.number_of_chirp, 
       v.max_sentiment, 
       v.min_sentiment, 
       v.average_sentiment, 
       v.starting_date, 
       v.ending_date
FROM parrotstatistics v
ORDER BY v.average_sentiment desc
LIMIT 3; /*4(b)*/


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE AddChirp(
	new_btag VARCHAR(30),
    loc_lat DECIMAL(10,6),
    loc_long DECIMAL(10,6),
    sentiment DECIMAL(2,1),
    content VARCHAR(255),
    orig_btag VARCHAR(30),
    orig_cno INT(11))
BEGIN
    DECLARE new_cno INT(11);
    DECLARE old_sentiment DECIMAL(10,6);
    DECLARE old_content VARCHAR(255);
	IF (orig_btag IS NULL) AND (orig_cno IS NULL)
		THEN 
		SET new_cno = 1+ 
					   (SELECT MAX(c.cno)
						FROM Chirp c
						WHERE c.btag = new_btag);
                        
		INSERT INTO Chirp(btag, 
						  cno, 
                          date,
						  location_latitude, 
						  location_longitude, 
						  parrots_btag,
						  parrots_cno,
						  sentiment,
						  text,
						  time)
                      
		VALUES(			  new_btag,
						  new_cno,
						  CURDATE(),
						  loc_lat,
						  loc_long,
						  null,
						  null,
						  sentiment,
						  content,
						  CURTIME());
	ELSE
		IF (sentiment IS NOT NULL) and (content IS NOT NULL)
        THEN
			SET new_cno = 1+ 
							(SELECT MAX(c.cno)
							 FROM Chirp c
							 WHERE c.btag = new_btag);
                        
			INSERT INTO Chirp(btag, 
							  cno, 
                              date,
						      location_latitude, 
						      location_longitude, 
						      parrots_btag,
						      parrots_cno,
						      sentiment,
						      text,
						      time)
                      
			VALUES(			  new_btag,
							  new_cno,
						      CURDATE(),
						      loc_lat,
						      loc_long,
						      orig_btag,
							  orig_cno,
						      sentiment,
						      content,
						      CURTIME());
		ELSE
			SET old_sentiment = (SELECT c.sentiment
								 FROM Bird b, Chirp c
                                 WHERE c.btag = b.btag and 
									   orig_btag = b.btag and
                                       orig_cno = c.cno);
			SET old_content = (SELECT c.sentiment
							   FROM Bird b, Chirp c
							   WHERE c.btag = b.btag and 
                                     orig_btag = b.btag and
									 orig_cno = c.cno);
			SET new_cno = 1+ 
							(SELECT MAX(c.cno)
							 FROM Chirp c
							 WHERE c.btag = new_btag);
                        
			INSERT INTO Chirp(btag, 
							  cno, 
                              date,
						      location_latitude, 
						      location_longitude, 
						      parrots_btag,
						      parrots_cno,
						      sentiment,
						      text,
						      time)
                      
			VALUES(			  new_btag,
							  new_cno,
						      CURDATE(),
						      loc_lat,
						      loc_long,
						      orig_btag,
							  orig_cno,
						      old_sentiment,
						      old_content,
						      CURTIME());
		END IF;
	END IF;
END $$ /*5(a)*/
DELIMITER ;

-- parrort_btag and parrort_cno is null
-- 'realDonaldTrump',0,'2017-02-11',-41.146717,-82.341417,NULL,NULL,-0.7,'A working dinner tonight with Prime Minister Abe of Japan and his representatives at the Winter White House (Mar-a-Lago). Very good talks!','23:24:08'),
CALL AddChirp('realDonaldTrump',0.0,0.0,-0.7,'A working dinner tonight with Prime Minister Abe of Japan and his representatives at the Winter White House (Mar-a-Lago). Very good talks!', NULL, NULL);
SELECT * FROM Chirp WHERE btag = 'realDonaldTrump'; /*5(b)*/

-- content and sentiment is null, parrort_btag and parrort_cno is not null
CALL AddChirp('HillaryClinton',0.0,0.0, NULL,NULL, 'realDonaldTrump', 7);
SELECT * FROM Chirp WHERE btag = 'HillaryClinton'; /*5(b)*/

-- content and sentiment is not null, parrort_btag and parrort_cno is not null
-- 'austin73',0,'2017-02-22',-4.679163,122.705400,'HillaryClinton',8,0.3,'Playing with Surface today. love the size. it is awesome','05:39:36')
CALL AddChirp('austin73',0.0,0.0,0.3,'Playing with Surface today. love the size. it is awesome','HillaryClinton',8);
SELECT * FROM Chirp WHERE btag = 'austin73'; /*5(b)*/





