-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: codeface
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.20.04.1

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
-- Table structure for table `author_commit_stats_view`
--

DROP TABLE IF EXISTS `author_commit_stats_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_commit_stats_view` (
  `Name` int DEFAULT NULL,
  `ID` int DEFAULT NULL,
  `releaseRangeId` int DEFAULT NULL,
  `added` int DEFAULT NULL,
  `deleted` int DEFAULT NULL,
  `total` int DEFAULT NULL,
  `numcommits` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cluster_user_pagerank_view`
--

DROP TABLE IF EXISTS `cluster_user_pagerank_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cluster_user_pagerank_view` (
  `id` int DEFAULT NULL,
  `personId` int DEFAULT NULL,
  `clusterId` int DEFAULT NULL,
  `technique` int DEFAULT NULL,
  `rankValue` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pagerank_view`
--

DROP TABLE IF EXISTS `pagerank_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagerank_view` (
  `pageRankId` int DEFAULT NULL,
  `authorId` int DEFAULT NULL,
  `name` int DEFAULT NULL,
  `rankValue` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `per_cluster_statistics_view`
--

DROP TABLE IF EXISTS `per_cluster_statistics_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `per_cluster_statistics_view` (
  `projectId` int DEFAULT NULL,
  `releaseRangeId` int DEFAULT NULL,
  `clusterId` int DEFAULT NULL,
  `technique` int DEFAULT NULL,
  `num_members` int DEFAULT NULL,
  `added` int DEFAULT NULL,
  `deleted` int DEFAULT NULL,
  `total` int DEFAULT NULL,
  `numcommits` int DEFAULT NULL,
  `prank_avg` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `per_person_cluster_statistics_view`
--

DROP TABLE IF EXISTS `per_person_cluster_statistics_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `per_person_cluster_statistics_view` (
  `projectId` int DEFAULT NULL,
  `releaseRangeId` int DEFAULT NULL,
  `clusterId` int DEFAULT NULL,
  `personId` int DEFAULT NULL,
  `technique` int DEFAULT NULL,
  `rankValue` int DEFAULT NULL,
  `added` int DEFAULT NULL,
  `deleted` int DEFAULT NULL,
  `total` int DEFAULT NULL,
  `numcommits` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `projectId` bigint NOT NULL,
  `email1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email3` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email4` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email5` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_email_project_idx` (`projectId`,`email1`),
  KEY `person_projectId_idx` (`projectId`),
  CONSTRAINT `person_projectId` FOREIGN KEY (`projectId`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `project` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `analysisMethod` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `analysisTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_range`
--

DROP TABLE IF EXISTS `release_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `release_range` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `projectId` bigint NOT NULL,
  `releaseStartId` bigint NOT NULL,
  `releaseEndId` bigint NOT NULL,
  `releaseRCStartId` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rr_project_idx` (`projectId`),
  KEY `rr_start_idx` (`releaseStartId`),
  KEY `rr_end_idx` (`releaseEndId`),
  KEY `rr_rc_start_idx` (`releaseRCStartId`),
  CONSTRAINT `rr_end_fk` FOREIGN KEY (`releaseEndId`) REFERENCES `release_timeline` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `rr_project_fk` FOREIGN KEY (`projectId`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rr_rc_start_fk` FOREIGN KEY (`releaseRCStartId`) REFERENCES `release_timeline` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `rr_start_fk` FOREIGN KEY (`releaseStartId`) REFERENCES `release_timeline` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `release_timeline`
--

DROP TABLE IF EXISTS `release_timeline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `release_timeline` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `projectId` bigint NOT NULL,
  `date` datetime NOT NULL,
  `tag` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rt_project_idx` (`projectId`),
  CONSTRAINT `rt_project_fk` FOREIGN KEY (`projectId`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `revisions_view`
--

DROP TABLE IF EXISTS `revisions_view`;
/*!50001 DROP VIEW IF EXISTS `revisions_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `revisions_view` AS SELECT 
 1 AS `projectId`,
 1 AS `releaseRangeID`,
 1 AS `date_start`,
 1 AS `date_end`,
 1 AS `date_rc_start`,
 1 AS `tag`,
 1 AS `cycle`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'codeface'
--
/*!50003 DROP PROCEDURE IF EXISTS `update_per_cluster_statistics` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,TRADITIONAL,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`codeface`@`localhost` PROCEDURE `update_per_cluster_statistics`()
BEGIN
	TRUNCATE per_cluster_statistics;
	INSERT INTO per_cluster_statistics SELECT * FROM per_cluster_statistics_view;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `revisions_view`
--

/*!50001 DROP VIEW IF EXISTS `revisions_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`codeface`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `revisions_view` AS select `p`.`id` AS `projectId`,`rr`.`id` AS `releaseRangeID`,`rt_s`.`date` AS `date_start`,`rt_e`.`date` AS `date_end`,`rt_rs`.`date` AS `date_rc_start`,`rt_s`.`tag` AS `tag`,concat(`rt_s`.`tag`,'-',`rt_e`.`tag`) AS `cycle` from ((((`release_range` `rr` join `release_timeline` `rt_s` on((`rr`.`releaseStartId` = `rt_s`.`id`))) join `release_timeline` `rt_e` on((`rr`.`releaseEndId` = `rt_e`.`id`))) left join `release_timeline` `rt_rs` on((`rr`.`releaseRCStartId` = `rt_rs`.`id`))) join `project` `p` on((`rr`.`projectId` = `p`.`id`))) order by `rr`.`id` */;
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

-- Dump completed on 2025-08-27 14:05:36
