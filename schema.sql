CREATE DATABASE  IF NOT EXISTS `f1_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `f1_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: f1_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `driver_race_stats`
--

DROP TABLE IF EXISTS `driver_race_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_race_stats` (
  `stat_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `fastest_lap_time` varchar(20) DEFAULT NULL,
  `avg_lap_time` varchar(20) DEFAULT NULL,
  `total_laps` int DEFAULT NULL,
  `laps_led` int DEFAULT NULL,
  `total_pit_stops` int DEFAULT NULL,
  PRIMARY KEY (`stat_id`),
  KEY `weekend_id` (`weekend_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `driver_race_stats_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `driver_race_stats_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4096 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `driver_standings`
--

DROP TABLE IF EXISTS `driver_standings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_standings` (
  `standing_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `points` float DEFAULT NULL,
  `position` int DEFAULT NULL,
  `wins` int DEFAULT NULL,
  PRIMARY KEY (`standing_id`),
  KEY `weekend_id` (`weekend_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `driver_standings_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `driver_standings_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drivers`
--

DROP TABLE IF EXISTS `drivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drivers` (
  `driver_id` int NOT NULL AUTO_INCREMENT,
  `driver_number` int NOT NULL,
  `driver_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`driver_id`),
  UNIQUE KEY `full_name` (`driver_name`),
  UNIQUE KEY `driver_name` (`driver_name`),
  CONSTRAINT `drivers_chk_1` CHECK ((`driver_number` between 0 and 99))
) ENGINE=InnoDB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `event_weekends`
--

DROP TABLE IF EXISTS `event_weekends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_weekends` (
  `weekend_id` int NOT NULL AUTO_INCREMENT,
  `round_number` int NOT NULL,
  `year` int NOT NULL,
  `country` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `event_name` varchar(100) DEFAULT NULL,
  `session1` varchar(50) DEFAULT NULL,
  `session1date` varchar(50) DEFAULT NULL,
  `session2` varchar(50) DEFAULT NULL,
  `session2date` varchar(50) DEFAULT NULL,
  `session3` varchar(50) DEFAULT NULL,
  `session3date` varchar(50) DEFAULT NULL,
  `session4` varchar(50) DEFAULT NULL,
  `session4date` varchar(50) DEFAULT NULL,
  `session5` varchar(50) DEFAULT NULL,
  `session5date` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`weekend_id`),
  UNIQUE KEY `round_number` (`round_number`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=2048 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lap_data`
--

DROP TABLE IF EXISTS `lap_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lap_data` (
  `lap_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `lap_number` int DEFAULT NULL,
  `lap_time` varchar(20) DEFAULT NULL,
  `stint` int DEFAULT NULL,
  `pit_out_time` varchar(20) DEFAULT NULL,
  `pit_in_time` varchar(20) DEFAULT NULL,
  `sector1_time` varchar(20) DEFAULT NULL,
  `sector2_time` varchar(20) DEFAULT NULL,
  `sector3_time` varchar(20) DEFAULT NULL,
  `is_personal_best` tinyint(1) DEFAULT NULL,
  `compound` varchar(20) DEFAULT NULL,
  `tyre_life` int DEFAULT NULL,
  `fresh_tyre` tinyint(1) DEFAULT NULL,
  `lap_start_time` varchar(20) DEFAULT NULL,
  `position` int DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`lap_id`),
  KEY `driver_id` (`driver_id`),
  KEY `idx_lap_data_weekend_driver` (`weekend_id`,`driver_id`),
  KEY `idx_lap_data_deleted` (`deleted`),
  KEY `idx_lap_data_compound` (`compound`),
  KEY `idx_lap_data_personal_best` (`is_personal_best`),
  CONSTRAINT `lap_data_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `lap_data_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=196606 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pit_stops`
--

DROP TABLE IF EXISTS `pit_stops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pit_stops` (
  `pit_stop_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `lap_number` int DEFAULT NULL,
  `pit_in_time` varchar(20) DEFAULT NULL,
  `pit_out_time` varchar(20) DEFAULT NULL,
  `stop_number` int DEFAULT NULL,
  PRIMARY KEY (`pit_stop_id`),
  KEY `weekend_id` (`weekend_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `pit_stops_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `pit_stops_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qualifying_results`
--

DROP TABLE IF EXISTS `qualifying_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qualifying_results` (
  `quali_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `qualifying_time` varchar(50) DEFAULT NULL,
  `qualifying_position` int DEFAULT NULL,
  PRIMARY KEY (`quali_id`),
  KEY `weekend_id` (`weekend_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `qualifying_results_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `qualifying_results_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `race_results`
--

DROP TABLE IF EXISTS `race_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `race_results` (
  `race_id` int NOT NULL AUTO_INCREMENT,
  `weekend_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `finishing_position` int DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  `points_earned` float DEFAULT NULL,
  PRIMARY KEY (`race_id`),
  KEY `weekend_id` (`weekend_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `race_results_ibfk_1` FOREIGN KEY (`weekend_id`) REFERENCES `event_weekends` (`weekend_id`),
  CONSTRAINT `race_results_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`driver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teams` (
  `team_id` int NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`team_id`),
  UNIQUE KEY `team_name` (`team_name`),
  UNIQUE KEY `team_name_2` (`team_name`),
  UNIQUE KEY `team_name_3` (`team_name`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-24 21:43:40
