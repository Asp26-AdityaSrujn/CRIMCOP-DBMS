-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: crimcop
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accused`
--

DROP TABLE IF EXISTS `accused`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accused` (
  `acc_id` int NOT NULL AUTO_INCREMENT,
  `case_id` int NOT NULL,
  `person_id` int NOT NULL,
  `arrest_date` date DEFAULT NULL,
  `status` enum('Arrested','Absconding','Surrendered') NOT NULL,
  `charge_section` varchar(100) NOT NULL,
  `remand_expiry` date DEFAULT NULL,
  PRIMARY KEY (`acc_id`),
  KEY `case_id` (`case_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `accused_ibfk_1` FOREIGN KEY (`case_id`) REFERENCES `crime_case` (`case_id`),
  CONSTRAINT `accused_ibfk_2` FOREIGN KEY (`person_id`) REFERENCES `person` (`p_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accused`
--

LOCK TABLES `accused` WRITE;
/*!40000 ALTER TABLE `accused` DISABLE KEYS */;
INSERT INTO `accused` VALUES (1,1,1,'2026-01-08','Arrested','IPC 379','2026-01-22'),(2,2,7,'2026-01-20','Arrested','IPC 302','2026-02-03'),(3,2,5,NULL,'Absconding','IPC 302',NULL),(4,3,7,'2026-02-10','Arrested','IPC 395','2026-02-24'),(5,3,13,NULL,'Absconding','IPC 395',NULL),(6,4,3,'2026-03-15','Arrested','IPC 323','2026-03-29'),(7,5,9,'2026-04-10','Arrested','IPC 411','2026-04-24'),(8,6,1,'2026-04-22','Arrested','IPC 379','2026-05-06'),(9,7,5,NULL,'Absconding','IPC 376',NULL),(10,8,13,'2026-05-25','Arrested','IPC 307','2026-06-08'),(11,9,15,'2026-06-08','Surrendered','IPC 370','2026-06-22'),(12,10,3,'2026-06-20','Arrested','IPC 457','2026-07-04'),(13,5,11,'2026-10-25','Arrested','IPC 411','2026-11-08'),(14,5,11,'2026-10-26','Arrested','IPC 411','2026-11-09'),(15,9,16,'2026-10-27','Arrested','IPC 379','2026-12-26'),(16,7,2,'2025-10-26','Arrested','IPC 307','2025-12-25'),(17,1,11,NULL,'Absconding','IPC 302',NULL);
/*!40000 ALTER TABLE `accused` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_accused_insert` AFTER INSERT ON `accused` FOR EACH ROW BEGIN
    
    IF NEW.status = 'Arrested' THEN
        UPDATE Person
        SET crim_rec_count = crim_rec_count + 1
        WHERE p_id = NEW.person_id;
    END IF;

    
    IF NEW.status = 'Absconding' THEN
        INSERT INTO Notice (accused_id, issued_station, iss_date, descr, status)
        SELECT 
            NEW.acc_id,
            f.ps_id,
            CURDATE(),
            CONCAT('Auto-generated lookout notice for absconding accused in Case ID: ', NEW.case_id),
            'Active'
        FROM Crime_Case cc
        JOIN FIR f ON cc.fir_id = f.fir_id
        WHERE cc.case_id = NEW.case_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `bail_record`
--

DROP TABLE IF EXISTS `bail_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bail_record` (
  `bail_id` int NOT NULL AUTO_INCREMENT,
  `accused_id` int NOT NULL,
  `ground_list` text NOT NULL,
  `grant_court` varchar(200) NOT NULL,
  `bail_amount` decimal(12,2) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `status` enum('Granted','Rejected','Revoked','Expired') NOT NULL,
  PRIMARY KEY (`bail_id`),
  KEY `accused_id` (`accused_id`),
  CONSTRAINT `bail_record_ibfk_1` FOREIGN KEY (`accused_id`) REFERENCES `accused` (`acc_id`),
  CONSTRAINT `bail_record_chk_1` CHECK (((`bail_amount` is null) or (`bail_amount` > 0)))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bail_record`
--

LOCK TABLES `bail_record` WRITE;
/*!40000 ALTER TABLE `bail_record` DISABLE KEYS */;
INSERT INTO `bail_record` VALUES (1,1,'No prior conviction, local resident, appeared cooperative','District Court Ongole',25000.00,'2026-04-22','Granted'),(2,2,'Serious offence IPC 302, denied bail','Sessions Court Ongole',NULL,NULL,'Rejected'),(3,4,'Bail granted with surety, accused has family ties in district','District Court Kurnool',50000.00,'2026-05-10','Granted'),(4,6,'Medical grounds cited, bail granted with conditions','District Court Guntur',30000.00,'2026-06-29','Granted'),(5,7,'Smuggling offence, bail denied due to flight risk','Sessions Court VJA',NULL,NULL,'Rejected'),(6,8,'Minor theft, first offence, bail granted','District Court VJA',10000.00,'2026-07-06','Granted'),(7,10,'Attempt to murder, bail denied','Sessions Court Kurnool',NULL,NULL,'Rejected'),(8,11,'Surrendered voluntarily, bail granted with travel restriction','District Court Nellore',40000.00,'2026-08-22','Granted'),(9,12,'First offence, bail granted with surety bond','District Court Guntur',20000.00,'2026-08-04','Granted'),(10,1,'Bail expired, accused failed to appear for hearing','District Court Ongole',NULL,'2026-04-22','Expired'),(11,13,'Serious smuggling offence, flight risk','Sessions Court Vijayawada',NULL,NULL,'Rejected'),(12,14,'Serious smuggling offence, flight risk','Sessions Court Vijawada',NULL,NULL,'Rejected'),(13,15,'5','2',NULL,NULL,'Rejected'),(14,16,'7','2',NULL,NULL,'Rejected');
/*!40000 ALTER TABLE `bail_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `beat_area`
--

DROP TABLE IF EXISTS `beat_area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `beat_area` (
  `bt_id` int NOT NULL AUTO_INCREMENT,
  `area` varchar(100) NOT NULL,
  `ps_id` int NOT NULL,
  `description` text,
  PRIMARY KEY (`bt_id`),
  KEY `ps_id` (`ps_id`),
  CONSTRAINT `beat_area_ibfk_1` FOREIGN KEY (`ps_id`) REFERENCES `policestation` (`ps_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `beat_area`
--

LOCK TABLES `beat_area` WRITE;
/*!40000 ALTER TABLE `beat_area` DISABLE KEYS */;
INSERT INTO `beat_area` VALUES (1,'Bus Stand Area',1,'High footfall commercial zone near central bus stand'),(2,'Market Zone',1,'Main vegetable and textile market area'),(3,'Residential Colony A',1,'Dense residential area, low crime density'),(4,'Highway Stretch NH44',2,'National highway section prone to vehicle theft'),(5,'Industrial Area',2,'APIIC industrial zone with warehouses'),(6,'Old Town',3,'Heritage area with narrow lanes'),(7,'Commercial Hub',3,'Banks, malls, and corporate offices'),(8,'Port Area',4,'Cargo port zone with high smuggling risk'),(9,'Railway Station Area',4,'High footfall transit zone'),(10,'Beach Road',5,'Coastal stretch with tourist activity');
/*!40000 ALTER TABLE `beat_area` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `case_evidence`
--

DROP TABLE IF EXISTS `case_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `case_evidence` (
  `case_id` int NOT NULL,
  `evd_id` int NOT NULL,
  `relevance` text,
  `linked_date` date NOT NULL,
  PRIMARY KEY (`case_id`,`evd_id`),
  KEY `evd_id` (`evd_id`),
  CONSTRAINT `case_evidence_ibfk_1` FOREIGN KEY (`case_id`) REFERENCES `crime_case` (`case_id`),
  CONSTRAINT `case_evidence_ibfk_2` FOREIGN KEY (`evd_id`) REFERENCES `evidence` (`evd_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `case_evidence`
--

LOCK TABLES `case_evidence` WRITE;
/*!40000 ALTER TABLE `case_evidence` DISABLE KEYS */;
INSERT INTO `case_evidence` VALUES (1,1,'Primary CCTV evidence identifying accused','2026-01-09'),(2,2,'Murder weapon found at scene','2026-01-21'),(2,4,'Blood group matches accused profile','2026-01-25'),(3,3,'Fake documents link accused to dacoity','2026-02-11'),(3,4,'Blood found on accused clothing matches victim','2026-02-15'),(4,5,'Weapon used in assault, fingerprints lifted','2026-03-16'),(5,6,'Port documents show forged cargo clearance','2026-04-11'),(5,7,'Contraband directly linked to Case 5 accused','2026-04-12'),(6,8,'CCTV confirms accused at scene of luggage theft','2026-04-23'),(7,4,'Biological evidence reused across Cases 3 and 7','2026-05-12'),(7,9,'DNA evidence links to accused in Case 7','2026-05-10'),(8,10,'Weapon recovered matches ballistic report','2026-05-26');
/*!40000 ALTER TABLE `case_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `court_proceeding`
--

DROP TABLE IF EXISTS `court_proceeding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `court_proceeding` (
  `proceeding_id` int NOT NULL AUTO_INCREMENT,
  `case_id` int NOT NULL,
  `court_name` varchar(200) NOT NULL,
  `hearing_date` date NOT NULL,
  `next_hearing` date DEFAULT NULL,
  `judge` varchar(100) DEFAULT NULL,
  `outcome` text,
  `status` enum('Scheduled','Completed','Adjourned') DEFAULT 'Scheduled',
  PRIMARY KEY (`proceeding_id`),
  KEY `case_id` (`case_id`),
  CONSTRAINT `court_proceeding_ibfk_1` FOREIGN KEY (`case_id`) REFERENCES `crime_case` (`case_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `court_proceeding`
--

LOCK TABLES `court_proceeding` WRITE;
/*!40000 ALTER TABLE `court_proceeding` DISABLE KEYS */;
/*!40000 ALTER TABLE `court_proceeding` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crime_case`
--

DROP TABLE IF EXISTS `crime_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crime_case` (
  `case_id` int NOT NULL AUTO_INCREMENT,
  `fir_id` int NOT NULL,
  `invest_off_id` int NOT NULL,
  `open_date` date NOT NULL,
  `close_date` date DEFAULT NULL,
  `status` enum('Active','Closed','Chargesheeted','Acquitted') DEFAULT 'Active',
  `summary` text,
  PRIMARY KEY (`case_id`),
  UNIQUE KEY `fir_id` (`fir_id`),
  KEY `invest_off_id` (`invest_off_id`),
  CONSTRAINT `crime_case_ibfk_1` FOREIGN KEY (`fir_id`) REFERENCES `fir` (`fir_id`),
  CONSTRAINT `crime_case_ibfk_2` FOREIGN KEY (`invest_off_id`) REFERENCES `officer` (`of_id`),
  CONSTRAINT `crime_case_chk_1` CHECK (((`close_date` is null) or (`close_date` >= `open_date`)))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crime_case`
--

LOCK TABLES `crime_case` WRITE;
/*!40000 ALTER TABLE `crime_case` DISABLE KEYS */;
INSERT INTO `crime_case` VALUES (1,1,2,'2026-01-06','2026-03-10','Chargesheeted','Accused identified via CCTV, chargesheet filed'),(2,2,3,'2026-01-16',NULL,'Active','Victim identified, forensics in progress'),(3,3,5,'2026-02-04','2026-10-25','Chargesheeted','Multiple accused, investigation ongoing|Chargesheet filed on2026-10-25'),(4,5,8,'2026-03-11',NULL,'Active','Witnesses examined, medical report obtained'),(5,7,10,'2026-04-06',NULL,'Active','Cargo seized, tracing supplier chain'),(6,8,11,'2026-04-20','2026-05-15','Closed','Stolen goods recovered, accused arrested'),(7,9,2,'2026-05-09',NULL,'Active','Medical examination done, accused absconding'),(8,10,5,'2026-05-21','2026-10-28','Closed','Victim stable, accused identified'),(9,11,12,'2026-06-03',NULL,'Active','Three suspects detained for questioning'),(10,12,8,'2026-06-16',NULL,'Active','Fingerprints lifted, locals questioned'),(11,13,3,'2026-10-25',NULL,'Active',NULL),(12,14,6,'2026-10-27',NULL,'Active',NULL),(13,15,7,'2026-10-28',NULL,'Active',NULL),(14,16,3,'2026-11-05',NULL,'Active',NULL);
/*!40000 ALTER TABLE `crime_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `duty`
--

DROP TABLE IF EXISTS `duty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `duty` (
  `of_id` int NOT NULL,
  `bt_id` int NOT NULL,
  `shift_type` enum('Morning','Evening','Night') NOT NULL,
  `duty_date` date NOT NULL,
  `vehicle_no` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`of_id`,`duty_date`,`shift_type`),
  KEY `bt_id` (`bt_id`),
  CONSTRAINT `duty_ibfk_1` FOREIGN KEY (`of_id`) REFERENCES `officer` (`of_id`),
  CONSTRAINT `duty_ibfk_2` FOREIGN KEY (`bt_id`) REFERENCES `beat_area` (`bt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `duty`
--

LOCK TABLES `duty` WRITE;
/*!40000 ALTER TABLE `duty` DISABLE KEYS */;
INSERT INTO `duty` VALUES (2,1,'Morning','2026-10-01','AP09TC1234'),(2,1,'Morning','2026-10-02','AP09TC1234'),(3,2,'Evening','2026-10-01','AP09TC5678'),(3,2,'Morning','2026-10-02','AP09TC5678'),(4,3,'Night','2026-10-01',NULL),(5,4,'Morning','2026-10-01','AP22AB3456'),(5,4,'Night','2026-10-02','AP22AB3456'),(6,5,'Evening','2026-10-01','AP22AB7890'),(7,5,'Night','2026-10-01',NULL),(8,6,'Morning','2026-10-01','AP07CD2345'),(10,8,'Morning','2026-10-01','AP16EF6789'),(11,9,'Evening','2026-10-01','AP16EF0123');
/*!40000 ALTER TABLE `duty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evidence`
--

DROP TABLE IF EXISTS `evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evidence` (
  `evd_id` int NOT NULL AUTO_INCREMENT,
  `off_id` int NOT NULL,
  `evd_type` enum('Weapon','Document','Digital','Biological','Other') NOT NULL,
  `col_date` date NOT NULL,
  `storage` varchar(200) DEFAULT NULL,
  `descr` text NOT NULL,
  `status` enum('In Custody','Submitted to Court','Destroyed') DEFAULT 'In Custody',
  PRIMARY KEY (`evd_id`),
  KEY `off_id` (`off_id`),
  CONSTRAINT `evidence_ibfk_1` FOREIGN KEY (`off_id`) REFERENCES `officer` (`of_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evidence`
--

LOCK TABLES `evidence` WRITE;
/*!40000 ALTER TABLE `evidence` DISABLE KEYS */;
INSERT INTO `evidence` VALUES (1,3,'Digital','2026-01-09','Server Room - Locker 3','CCTV footage of theft at bus stand','In Custody'),(2,3,'Weapon','2026-01-21','Evidence Room - Rack 1','Knife used in murder, bloodstained','In Custody'),(3,5,'Document','2026-02-11','Evidence Room - Rack 2','Fake invoice documents seized from truck','In Custody'),(4,5,'Biological','2026-02-12','Forensic Lab','Blood samples from crime scene on highway','In Custody'),(5,8,'Weapon','2026-03-16','Evidence Room - Rack 3','Iron rod used in assault','Submitted to Court'),(6,10,'Document','2026-04-11','Evidence Room - Rack 4','Seized cargo manifests and port documents','In Custody'),(7,10,'Other','2026-04-12','Warehouse B','Contraband goods seized at port checkpoint','In Custody'),(8,11,'Digital','2026-04-23','Server Room - Locker 5','Station CCTV showing luggage theft','Submitted to Court'),(9,2,'Biological','2026-05-10','Forensic Lab','DNA evidence from assault scene MG Road','In Custody'),(10,5,'Weapon','2026-05-26','Evidence Room - Rack 5','Country-made pistol recovered from accused','In Custody'),(11,12,'Document','2026-06-09','Evidence Room - Rack 6','Victim travel records and phone transcripts','In Custody'),(12,8,'Digital','2026-06-21','Server Room - Locker 6','Photos of broken lock and stolen items','In Custody');
/*!40000 ALTER TABLE `evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fir`
--

DROP TABLE IF EXISTS `fir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fir` (
  `fir_id` int NOT NULL AUTO_INCREMENT,
  `ps_id` int NOT NULL,
  `reg_off_id` int NOT NULL,
  `comp_per_id` int NOT NULL,
  `beat_id` int DEFAULT NULL,
  `time_filed` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `incident_date` date NOT NULL,
  `location` varchar(200) NOT NULL,
  `section` varchar(100) NOT NULL,
  `descr` text NOT NULL,
  `status` enum('Open','Under Investigation','Closed','Chargesheeted') DEFAULT 'Open',
  PRIMARY KEY (`fir_id`),
  KEY `ps_id` (`ps_id`),
  KEY `reg_off_id` (`reg_off_id`),
  KEY `comp_per_id` (`comp_per_id`),
  KEY `beat_id` (`beat_id`),
  CONSTRAINT `fir_ibfk_1` FOREIGN KEY (`ps_id`) REFERENCES `policestation` (`ps_id`),
  CONSTRAINT `fir_ibfk_2` FOREIGN KEY (`reg_off_id`) REFERENCES `officer` (`of_id`),
  CONSTRAINT `fir_ibfk_3` FOREIGN KEY (`comp_per_id`) REFERENCES `person` (`p_id`),
  CONSTRAINT `fir_ibfk_4` FOREIGN KEY (`beat_id`) REFERENCES `beat_area` (`bt_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fir`
--

LOCK TABLES `fir` WRITE;
/*!40000 ALTER TABLE `fir` DISABLE KEYS */;
INSERT INTO `fir` VALUES (1,1,2,2,1,'2026-01-05 10:30:00','2026-01-04','Bus Stand, Ongole','IPC 379','Theft of mobile phone at bus stand','Chargesheeted'),(2,1,3,6,2,'2026-01-15 14:00:00','2026-01-14','Market Zone, Ongole','IPC 302','Murder at market, victim found stabbed','Under Investigation'),(3,2,5,10,4,'2026-02-03 09:15:00','2026-02-02','NH44, Kurnool','IPC 395','Dacoity on highway, cash stolen from truck','Under Investigation'),(4,2,6,14,5,'2026-02-18 16:45:00','2026-02-17','Industrial Area, Kurnool','IPC 420','Fraud at warehouse, fake goods supplied','Open'),(5,3,8,2,6,'2026-03-10 11:00:00','2026-03-09','Old Town, Guntur','IPC 323','Assault and grievous hurt in old town lane','Under Investigation'),(6,3,8,4,7,'2026-03-22 08:30:00','2026-03-21','Commercial Hub, Guntur','IPC 138 NI','Cheque bounce fraud at local bank','Open'),(7,4,10,6,8,'2026-04-05 13:20:00','2026-04-04','Port Area, Vijayawada','IPC 411','Smuggling of contraband via port cargo','Under Investigation'),(8,4,11,8,9,'2026-04-19 07:45:00','2026-04-18','Railway Station, VJA','IPC 379','Luggage theft at railway station','Closed'),(9,1,2,10,1,'2026-05-08 15:10:00','2026-05-07','MG Road, Ongole','IPC 376','Sexual assault reported near MG Road','Under Investigation'),(10,2,5,12,4,'2026-05-20 10:00:00','2026-05-19','Kurnool Bus Depot','IPC 307','Attempt to murder at bus depot','Under Investigation'),(11,5,12,4,10,'2026-06-02 09:00:00','2026-06-01','Beach Road, Nellore','IPC 370','Human trafficking suspected near beach road','Under Investigation'),(12,3,8,6,6,'2026-06-15 14:30:00','2026-06-14','Old Town, Guntur','IPC 457','House breaking and theft at old town','Open'),(13,1,2,3,1,'2026-10-25 23:20:36','2026-10-24','Railway Road, Ongole','IPC 379','Theft of two-wheeler reported near railway road','Under Investigation'),(14,3,7,15,6,'2026-10-27 20:51:58','2026-10-27','Centre X Roads','379','Attacked','Under Investigation'),(15,4,3,7,9,'2026-10-28 15:38:24','2026-10-26','Platform 7','379','Robery','Under Investigation'),(16,1,2,3,1,'2026-11-05 17:26:37','2026-10-24','Railway Road, Ongole','IPC 379','Theft of two-wheeler reported ','Under Investigation');
/*!40000 ALTER TABLE `fir` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice`
--

DROP TABLE IF EXISTS `notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notice` (
  `not_id` int NOT NULL AUTO_INCREMENT,
  `accused_id` int NOT NULL,
  `issued_station` int NOT NULL,
  `iss_date` date NOT NULL,
  `descr` text,
  `status` enum('Active','Withdrawn','Executed') DEFAULT 'Active',
  PRIMARY KEY (`not_id`),
  KEY `accused_id` (`accused_id`),
  KEY `issued_station` (`issued_station`),
  CONSTRAINT `notice_ibfk_1` FOREIGN KEY (`accused_id`) REFERENCES `accused` (`acc_id`),
  CONSTRAINT `notice_ibfk_2` FOREIGN KEY (`issued_station`) REFERENCES `policestation` (`ps_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice`
--

LOCK TABLES `notice` WRITE;
/*!40000 ALTER TABLE `notice` DISABLE KEYS */;
INSERT INTO `notice` VALUES (1,3,1,'2026-01-22','Accused Vikram Singh absconding in IPC 302 murder case, last seen Ongole bus stand area','Active'),(2,5,1,'2026-02-12','Accused Vikram Singh also wanted in dacoity Case 3, armed and dangerous','Active'),(3,5,2,'2026-02-14','Lookout for Vikram Singh circulated to Kurnool North station','Active'),(4,9,1,'2026-05-11','Accused Vikram Singh absconding in sexual assault case, do not approach alone','Active'),(5,5,3,'2026-02-18','Aakash Verma absconding in dacoity case, known to operate in Guntur district','Active'),(6,5,4,'2026-02-20','Aakash Verma lookout notice circulated to Vijayawada West station','Withdrawn'),(7,3,2,'2026-10-25','Accused spotted near Kurnool bus depot, approach with caution','Active'),(8,5,2,'2026-10-26','Testing','Active'),(9,6,2,'2026-10-26','Criminal missing','Active'),(10,17,1,'2026-11-05','Auto-generated lookout notice for absconding accused in Case ID: 1','Active');
/*!40000 ALTER TABLE `notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `officer`
--

DROP TABLE IF EXISTS `officer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `officer` (
  `of_id` int NOT NULL AUTO_INCREMENT,
  `of_name` varchar(60) NOT NULL,
  `batch` varchar(20) NOT NULL,
  `designation` varchar(30) NOT NULL,
  `status` enum('Active','Suspended','Retired') DEFAULT 'Active',
  `ps_id` int NOT NULL,
  `contact` varchar(25) DEFAULT NULL,
  `doj` date NOT NULL,
  PRIMARY KEY (`of_id`),
  KEY `ps_id` (`ps_id`),
  CONSTRAINT `officer_ibfk_1` FOREIGN KEY (`ps_id`) REFERENCES `policestation` (`ps_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `officer`
--

LOCK TABLES `officer` WRITE;
/*!40000 ALTER TABLE `officer` DISABLE KEYS */;
INSERT INTO `officer` VALUES (1,'Ramesh Kumar','IPS2010','ACP','Active',1,'9876540001','2010-06-15'),(2,'Priya Sharma','IPS2015','Inspector','Active',1,'9876540002','2015-03-20'),(3,'Venkat Rao','AP2016','SI','Active',1,'9876540003','2016-07-01'),(4,'Suresh Babu','AP2019','Constable','Active',1,'9876540004','2019-01-10'),(5,'Anil Mehta','IPS2012','Inspector','Active',2,'9876540005','2012-09-05'),(6,'Lakshmi Devi','AP2017','SI','Active',2,'9876540006','2017-04-22'),(7,'Ravi Teja','AP2020','Constable','Active',2,'9876540007','2020-08-15'),(8,'Gopal Reddy','IPS2013','Inspector','Active',3,'9876540008','2013-11-30'),(9,'Kavitha Nair','AP2018','SI','Suspended',3,'9876540009','2018-02-14'),(10,'Arjun Sharma','IPS2014','Inspector','Active',4,'9876540010','2014-05-18'),(11,'Deepak Verma','AP2018','SI','Active',4,'9876540011','2018-06-30'),(12,'Srinivas Rao','IPS2011','Inspector','Retired',5,'9876540012','2011-12-01');
/*!40000 ALTER TABLE `officer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `p_id` int NOT NULL AUTO_INCREMENT,
  `p_name` varchar(100) NOT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `aadhaar_no` varchar(12) DEFAULT NULL,
  `contact` varchar(25) DEFAULT NULL,
  `p_type` enum('Criminal','Victim','Witness') NOT NULL,
  `crim_rec_count` int DEFAULT '0',
  PRIMARY KEY (`p_id`),
  UNIQUE KEY `aadhaar_no` (`aadhaar_no`),
  CONSTRAINT `person_chk_1` CHECK ((`crim_rec_count` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,'Mohammed Salim','1985-03-12','Male','234567890123','9000001001','Criminal',3),(2,'Ramya Krishnan','1990-07-25','Female','345678901234','9000001002','Victim',1),(3,'Karthik Subramani','1978-11-08','Male','456789012345','9000001003','Criminal',1),(4,'Anitha Reddy','1995-02-14','Female','567890123456','9000001004','Witness',0),(5,'Vikram Singh','1982-09-30','Male','678901234567','9000001005','Criminal',2),(6,'Sunita Patel','1988-06-19','Female','789012345678','9000001006','Victim',0),(7,'Raju Yadav','1975-01-05','Male','890123456789','9000001007','Criminal',4),(8,'Divya Menon','1993-08-22','Female','901234567890','9000001008','Witness',0),(9,'Prakash Nair','1980-12-17','Male','012345678901','9000001009','Criminal',1),(10,'Savitha Rao','1992-04-03','Female','123456789012','9000001010','Victim',0),(11,'Sunil Gupta','1987-10-28','Male','234567890124','9000001011','Criminal',2),(12,'Preethi Kumar','1996-05-15','Female','345678901235','9000001012','Witness',0),(13,'Aakash Verma','1983-07-09','Male','456789012346','9000001013','Criminal',2),(14,'Meena Pillai','1991-03-27','Female','567890123457','9000001014','Victim',0),(15,'Harish Chand','1979-11-20','Male','678901234568','9000001015','Criminal',1),(16,'Sumantha Mishra','1990-09-09','Male','123456780912','1111555566','Witness',1),(17,'Amithab Bachchan','1975-10-16','Male','678967896789','9685743201','Criminal',0);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `policestation`
--

DROP TABLE IF EXISTS `policestation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `policestation` (
  `ps_id` int NOT NULL AUTO_INCREMENT,
  `ps_name` varchar(100) NOT NULL,
  `ps_address` text NOT NULL,
  `area` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `contact` varchar(25) NOT NULL,
  PRIMARY KEY (`ps_id`),
  UNIQUE KEY `contact` (`contact`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policestation`
--

LOCK TABLES `policestation` WRITE;
/*!40000 ALTER TABLE `policestation` DISABLE KEYS */;
INSERT INTO `policestation` VALUES (1,'Ongole Central','12 MG Road','Ongole','Prakasam','Andhra Pradesh','9100001001'),(2,'Kurnool North','45 Station Road','Kurnool','Kurnool','Andhra Pradesh','9100001002'),(3,'Guntur East','7 Brodipet Main Road','Guntur','Guntur','Andhra Pradesh','9100001003'),(4,'Vijayawada West','23 Eluru Road','Vijayawada','Krishna','Andhra Pradesh','9100001004'),(5,'Nellore South','89 Grand Trunk Road','Nellore','Nellore','Andhra Pradesh','9100001005');
/*!40000 ALTER TABLE `policestation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `upcoming_hearings`
--

DROP TABLE IF EXISTS `upcoming_hearings`;
/*!50001 DROP VIEW IF EXISTS `upcoming_hearings`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `upcoming_hearings` AS SELECT 
 1 AS `proceeding_id`,
 1 AS `case_id`,
 1 AS `station`,
 1 AS `court_name`,
 1 AS `hearing_date`,
 1 AS `judge`,
 1 AS `hearing_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `upcoming_hearings`
--

/*!50001 DROP VIEW IF EXISTS `upcoming_hearings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `upcoming_hearings` AS select `cp`.`proceeding_id` AS `proceeding_id`,`cc`.`case_id` AS `case_id`,`ps`.`ps_name` AS `station`,`cp`.`court_name` AS `court_name`,`cp`.`hearing_date` AS `hearing_date`,`cp`.`judge` AS `judge`,`cp`.`status` AS `hearing_status` from (((`court_proceeding` `cp` join `crime_case` `cc` on((`cp`.`case_id` = `cc`.`case_id`))) join `fir` `f` on((`cc`.`fir_id` = `f`.`fir_id`))) join `policestation` `ps` on((`f`.`ps_id` = `ps`.`ps_id`))) where ((`cp`.`status` = 'Scheduled') and (`cp`.`hearing_date` >= curdate())) order by `cp`.`hearing_date` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-11 19:02:48
