use gpstracker;
DROP TABLE IF EXISTS `gpslocations`;


CREATE TABLE `gpslocations` (
  `GPSLocationID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `lastUpdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `latitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `longitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `phoneNumber` varchar(50) NOT NULL DEFAULT '',
  `userName` varchar(50) NOT NULL DEFAULT '',
  `sessionID` varchar(50) NOT NULL DEFAULT '',
  `speed` int(10) unsigned NOT NULL DEFAULT '0',
  `direction` int(10) unsigned NOT NULL DEFAULT '0',
  `distance` decimal(10,1) NOT NULL DEFAULT '0.0',
  `gpsTime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `locationMethod` varchar(50) NOT NULL DEFAULT '',
  `accuracy` int(10) unsigned NOT NULL DEFAULT '0',
  `extraInfo` varchar(255) NOT NULL DEFAULT '',
  `eventType` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`GPSLocationID`),
  KEY `sessionIDIndex` (`sessionID`),
  KEY `phoneNumberIndex` (`phoneNumber`),
  KEY `userNameIndex` (`userName`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

LOCK TABLES `gpslocations` WRITE;

INSERT INTO `gpslocations` VALUES (1,'2007-01-03 19:37:00',47.627327,-122.325691,'gpsTracker3','gpsTracker3','8BA21D90-3F90-407F-BAAE-800B04B1F5EB',0,0,0.0,'2007-01-03 19:37:00','na',137,'na','gpsTracker'),(2,'2007-01-03 19:38:00',47.607258,-122.330077,'gpsTracker3','gpsTracker3','8BA21D90-3F90-407F-BAAE-800B04B1F5EB',0,0,0.0,'2007-01-03 19:38:00','na',137,'na','gpsTracker'),(3,'2007-01-03 19:39:00',47.601703,-122.324670,'gpsTracker3','gpsTracker3','8BA21D90-3F90-407F-BAAE-800B04B1F5EB',0,0,0.0,'2007-01-03 19:39:00','na',137,'na','gpsTracker'),(4,'0000-00-00 00:00:00',47.593757,-122.195074,'gpsTracker2','gpsTracker2','8BA21D90-3F90-407F-BAAE-800B04B1F5EC',0,0,0.0,'2007-01-03 19:40:00','na',137,'na','gpsTracker'),(5,'2007-01-03 19:41:00',47.601397,-122.190353,'gpsTracker2','gpsTracker2','8BA21D90-3F90-407F-BAAE-800B04B1F5EC',0,0,0.0,'2007-01-03 19:41:00','na',137,'na','gpsTracker'),(6,'2007-01-03 19:42:00',47.610020,-122.190697,'gpsTracker2','gpsTracker2','8BA21D90-3F90-407F-BAAE-800B04B1F5EC',0,0,0.0,'2007-01-03 19:42:00','na',137,'na','gpsTracker'),(7,'2007-01-03 19:43:00',47.636631,-122.214558,'gpsTracker1','gpsTracker1','8BA21D90-3F90-407F-BAAE-800B04B1F5ED',0,0,0.0,'2007-01-03 19:43:00','na',137,'na','gpsTracker'),(8,'2007-01-03 19:44:00',47.637961,-122.201769,'gpsTracker1','gpsTracker1','8BA21D90-3F90-407F-BAAE-800B04B1F5ED',0,0,0.0,'2007-01-03 19:44:00','na',137,'na','gpsTracker'),(9,'2007-01-03 19:45:00',47.642935,-122.209579,'gpsTracker1','gpsTracker1','8BA21D90-3F90-407F-BAAE-800B04B1F5ED',0,0,0.0,'2007-01-03 19:45:00','na',137,'na','gpsTracker');
/*!40000 ALTER TABLE `gpslocations` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetAllRoutesForMap`()
BEGIN
  SELECT DISTINCT(sessionId), MAX(gpsTime) gpsTime, 
  CONCAT('{ "latitude":"', CAST(latitude AS CHAR),'", "longitude":"', CAST(longitude AS CHAR), '", "speed":"', CAST(speed AS CHAR), '", "direction":"', CAST(direction AS CHAR), '", "distance":"', CAST(distance AS CHAR), '", "locationMethod":"', locationMethod, '", "gpsTime":"', DATE_FORMAT(gpsTime, '%b %e %Y %h:%i%p'), '", "userName":"', userName, '", "phoneNumber":"', phoneNumber, '", "sessionID":"', CAST(sessionID AS CHAR), '", "accuracy":"', CAST(accuracy AS CHAR), '", "extraInfo":"', extraInfo, '" }') json
  FROM gpslocations
  WHERE sessionID != '0' && CHAR_LENGTH(sessionID) != 0 && gpstime != '0000-00-00 00:00:00'
  GROUP BY sessionID;
END ;;
DELIMITER ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetRouteForMap`(
_sessionID VARCHAR(50))
BEGIN
  SELECT CONCAT('{ "latitude":"', CAST(latitude AS CHAR),'", "longitude":"', CAST(longitude AS CHAR), '", "speed":"', CAST(speed AS CHAR), '", "direction":"', CAST(direction AS CHAR), '", "distance":"', CAST(distance AS CHAR), '", "locationMethod":"', locationMethod, '", "gpsTime":"', DATE_FORMAT(gpsTime, '%b %e %Y %h:%i%p'), '", "userName":"', userName, '", "phoneNumber":"', phoneNumber, '", "sessionID":"', CAST(sessionID AS CHAR), '", "accuracy":"', CAST(accuracy AS CHAR), '", "extraInfo":"', extraInfo, '" }') json
  FROM gpslocations
  WHERE sessionID = _sessionID
  ORDER BY lastupdate;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `prcGetRoutes`()
BEGIN
  CREATE TEMPORARY TABLE tempRoutes (
    sessionID VARCHAR(50),
    userName VARCHAR(50),
    startTime DATETIME,
    endTime DATETIME)
  ENGINE = MEMORY;

  INSERT INTO tempRoutes (sessionID, userName)
  SELECT DISTINCT sessionID, userName
  FROM gpslocations;

  UPDATE tempRoutes tr
  SET startTime = (SELECT MIN(gpsTime) FROM gpslocations gl
  WHERE gl.sessionID = tr.sessionID
  AND gl.userName = tr.userName);

  UPDATE tempRoutes tr
  SET endTime = (SELECT MAX(gpsTime) FROM gpslocations gl
  WHERE gl.sessionID = tr.sessionID
  AND gl.userName = tr.userName);

  SELECT

  CONCAT('{ "sessionID": "', CAST(sessionID AS CHAR),  '", "userName": "', userName, '", "times": "(', DATE_FORMAT(startTime, '%b %e %Y %h:%i%p'), ' - ', DATE_FORMAT(endTime, '%b %e %Y %h:%i%p'), ')" }') json
  FROM tempRoutes
  ORDER BY startTime DESC;

  DROP TABLE tempRoutes;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `prcSaveGPSLocation`(
_latitude DECIMAL(10,7),
_longitude DECIMAL(10,7),
_speed INT(10),
_direction INT(10),
_distance DECIMAL(10,1),
_date TIMESTAMP,
_locationMethod VARCHAR(50),
_userName VARCHAR(50),
_phoneNumber VARCHAR(50),
_sessionID VARCHAR(50),
_accuracy INT(10),
_extraInfo VARCHAR(255),
_eventType VARCHAR(50)
)
BEGIN
   INSERT INTO gpslocations (latitude, longitude, speed, direction, distance, gpsTime, locationMethod, userName, phoneNumber,  sessionID, accuracy, extraInfo, eventType)
   VALUES (_latitude, _longitude, _speed, _direction, _distance, _date, _locationMethod, _userName, _phoneNumber, _sessionID, _accuracy, _extraInfo, _eventType);
   SELECT NOW();
END ;;
DELIMITER ;
