-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema codeface
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `codeface` DEFAULT CHARACTER SET utf8 ;
USE `codeface` ;

-- -----------------------------------------------------
-- Table `project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `project` ;
CREATE TABLE IF NOT EXISTS `project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `analysisMethod` VARCHAR(45) NOT NULL,
  `analysisTime` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `person` ;
CREATE TABLE IF NOT EXISTS `person` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `email1` VARCHAR(255) NOT NULL,
  `email2` VARCHAR(255) NULL DEFAULT NULL,
  `email3` VARCHAR(255) NULL DEFAULT NULL,
  `email4` VARCHAR(255) NULL DEFAULT NULL,
  `email5` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `person_projectId_idx` (`projectId` ASC),
  UNIQUE INDEX `person_email_project_idx` (`projectId` ASC, `email1` ASC),
  CONSTRAINT `person_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `release_timeline`;
CREATE TABLE `release_timeline` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `date` DATETIME NOT NULL,
  `tag` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rt_project_idx` (`projectId`),
  CONSTRAINT `rt_project_fk`
    FOREIGN KEY (`projectId`) REFERENCES `project`(`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `release_range`;
CREATE TABLE `release_range` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `releaseStartId` BIGINT NOT NULL,
  `releaseEndId` BIGINT NOT NULL,
  `releaseRCStartId` BIGINT NULL,
  PRIMARY KEY (`id`),
  KEY `rr_project_idx` (`projectId`),
  KEY `rr_start_idx` (`releaseStartId`),
  KEY `rr_end_idx` (`releaseEndId`),
  KEY `rr_rc_start_idx` (`releaseRCStartId`),
  CONSTRAINT `rr_project_fk`
    FOREIGN KEY (`projectId`) REFERENCES `project`(`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rr_start_fk`
    FOREIGN KEY (`releaseStartId`) REFERENCES `release_timeline`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `rr_end_fk`
    FOREIGN KEY (`releaseEndId`) REFERENCES `release_timeline`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `rr_rc_start_fk`
    FOREIGN KEY (`releaseRCStartId`) REFERENCES `release_timeline`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- (… tutte le tabelle come già definite, nessuna modifica necessaria …)
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Placeholder tables for views (pulite)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `revisions_view` (
  `projectId` INT,
  `releaseRangeID` INT,
  `date_start` INT,
  `date_end` INT,
  `date_rc_start` INT,
  `tag` INT,
  `cycle` INT
);

CREATE TABLE IF NOT EXISTS `author_commit_stats_view` (
  `Name` INT,
  `ID` INT,
  `releaseRangeId` INT,
  `added` INT,
  `deleted` INT,
  `total` INT,
  `numcommits` INT
);

CREATE TABLE IF NOT EXISTS `per_person_cluster_statistics_view` (
  `projectId` INT,
  `releaseRangeId` INT,
  `clusterId` INT,
  `personId` INT,
  `technique` INT,
  `rankValue` INT,
  `added` INT,
  `deleted` INT,
  `total` INT,
  `numcommits` INT
);

CREATE TABLE IF NOT EXISTS `cluster_user_pagerank_view` (
  `id` INT,
  `personId` INT,
  `clusterId` INT,
  `technique` INT,
  `rankValue` INT
);

CREATE TABLE IF NOT EXISTS `per_cluster_statistics_view` (
  `projectId` INT,
  `releaseRangeId` INT,
  `clusterId` INT,
  `technique` INT,
  `num_members` INT,
  `added` INT,
  `deleted` INT,
  `total` INT,
  `numcommits` INT,
  `prank_avg` INT
);

CREATE TABLE IF NOT EXISTS `pagerank_view` (
  `pageRankId` INT,
  `authorId` INT,
  `name` INT,
  `rankValue` INT
);

-- -----------------------------------------------------
-- Procedure e viste
-- -----------------------------------------------------
USE `codeface`;
DROP PROCEDURE IF EXISTS `update_per_cluster_statistics`;

DELIMITER $$
CREATE PROCEDURE `update_per_cluster_statistics` ()
BEGIN
	TRUNCATE per_cluster_statistics;
	INSERT INTO per_cluster_statistics SELECT * FROM per_cluster_statistics_view;
END$$
DELIMITER ;

-- Views (le tue definizioni già ci sono, le lascio uguali)
-- -----------------------------------------------------
DROP VIEW IF EXISTS `revisions_view` ;
DROP TABLE IF EXISTS `revisions_view`;
CREATE OR REPLACE VIEW `revisions_view` AS
SELECT 
  p.id as projectId,
  rr.id as releaseRangeID,
  rt_s.date as date_start, 
  rt_e.date as date_end, 
  rt_rs.date as date_rc_start, 
  rt_s.tag as tag, 
  concat(rt_s.tag,'-',rt_e.tag) as cycle
FROM 
  release_range rr 
  JOIN release_timeline rt_s ON rr.releaseStartId = rt_s.id
  JOIN release_timeline rt_e ON rr.releaseEndId = rt_e.id
  LEFT JOIN release_timeline rt_rs ON rr.releaseRCStartId = rt_rs.id
  JOIN project p ON rr.projectId = p.id
ORDER BY rr.id ASC;

-- (… e tutte le altre viste già definite …)

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
