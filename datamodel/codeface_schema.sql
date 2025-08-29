-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema codeface
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema codeface
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `codeface`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `codeface` ;

-- -----------------------------------------------------
-- Table  `project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS project ;

CREATE TABLE IF NOT EXISTS project (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `analysisMethod` VARCHAR(45) NOT NULL,
  `analysisTime` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC))
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `person` ;

CREATE TABLE IF NOT EXISTS  `person` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
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
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `issue`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `issue` ;

CREATE TABLE IF NOT EXISTS  `issue` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `bugId` VARCHAR(45) NOT NULL,
  `creationDate` DATETIME NOT NULL,
  `modifiedDate` DATETIME NULL DEFAULT NULL,
  `url` VARCHAR(255) NULL DEFAULT NULL,
  `isRegression` INT(1) NULL DEFAULT 0,
  `status` VARCHAR(45) NOT NULL,
  `resolution` VARCHAR(45) NULL DEFAULT NULL,
  `priority` VARCHAR(45) NOT NULL,
  `severity` VARCHAR(45) NOT NULL,
  `createdBy` BIGINT NOT NULL,
  `assignedTo` BIGINT NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `subComponent` VARCHAR(45) NULL DEFAULT NULL,
  `subSubComponent` VARCHAR(45) NULL DEFAULT NULL,
  `version` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `issue_createdBy_idx` (`createdBy` ASC),
  INDEX `issue_assignedTo_idx` (`assignedTo` ASC),
  INDEX `issue_projectId_idx` (`projectId` ASC),
  UNIQUE INDEX `bugId_UNIQUE` (`bugId` ASC),
  CONSTRAINT `issue_createdBy`
    FOREIGN KEY (`createdBy`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_assignedTo`
    FOREIGN KEY (`assignedTo`)
    REFERENCES  `person` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `issue_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table  `issue_comment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `issue_comment` ;

CREATE TABLE IF NOT EXISTS  `issue_comment` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `who` BIGINT NOT NULL,
  `fk_issueId` BIGINT NOT NULL,
  `commentDate` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_issueId_idx` (`fk_issueId` ASC),
  INDEX `issue_comment_who_idx` (`who` ASC),
  CONSTRAINT `fk_issueId`
    FOREIGN KEY (`fk_issueId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_comment_who`
    FOREIGN KEY (`who`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table  `release_timeline`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `release_timeline` ;

CREATE TABLE IF NOT EXISTS  `release_timeline` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(45) NOT NULL,
  `tag` VARCHAR(45) NOT NULL,
  `date` DATETIME NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `release_project_ref_idx` (`projectId` ASC),
  CONSTRAINT `release_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `release_range`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `release_range` ;

CREATE TABLE IF NOT EXISTS  `release_range` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `releaseStartId` BIGINT NOT NULL,
  `releaseEndId` BIGINT NOT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRCStartId` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `releaseRange_releaseStartId_idx` (`releaseStartId` ASC),
  INDEX `releaseRange_releaseEndId_idx` (`releaseEndId` ASC),
  INDEX `releaseRange_projectId_idx` (`projectId` ASC),
  INDEX `releaseRange_RCStartId_idx` (`releaseRCStartId` ASC),
  CONSTRAINT `releaseRange_releaseStartId`
    FOREIGN KEY (`releaseStartId`)
    REFERENCES  `release_timeline` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_releaseEndId`
    FOREIGN KEY (`releaseEndId`)
    REFERENCES  `release_timeline` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRange_RCStartId`
    FOREIGN KEY (`releaseRCStartId`)
    REFERENCES  `release_timeline` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table  `mailing_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `mailing_list` ;

CREATE TABLE IF NOT EXISTS  `mailing_list` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `description` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  INDEX `mailing_lists_projectid_idx` (`projectId` ASC),
  CONSTRAINT `mailing_lists_projectid`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `mail_thread`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `mail_thread` ;

CREATE TABLE IF NOT EXISTS  `mail_thread` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `subject` VARCHAR(255) NULL DEFAULT NULL,
  `createdBy` BIGINT NULL DEFAULT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `mailThreadId` BIGINT NOT NULL,
  `creationDate` DATETIME NULL DEFAULT NULL,
  `numberOfAuthors` INT NOT NULL,
  `numberOfMessages` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `mail_createdBy_idx` (`createdBy` ASC),
  INDEX `mail_projectId_idx` (`projectId` ASC),
  INDEX `mail_release_range_key_idx` (`releaseRangeId` ASC),
  INDEX `mail_mlId_idx` (`mlId` ASC),
  CONSTRAINT `thread_createdBy`
    FOREIGN KEY (`createdBy`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `thread_release_range_key`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `thread_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `thread_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `thread_responses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `thread_responses` ;

CREATE TABLE IF NOT EXISTS  `thread_responses` (
  `who` BIGINT NOT NULL,
  `mailThreadId` BIGINT NOT NULL,
  `mailDate` DATETIME NULL DEFAULT NULL,
  INDEX `thread_responses_who_idx` (`who` ASC),
  INDEX `mailThreadId_idx` (`mailThreadId` ASC),
  CONSTRAINT `thread_responses_who`
    FOREIGN KEY (`who`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mailThreadId`
    FOREIGN KEY (`mailThreadId`)
    REFERENCES  `mail_thread` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `cc_list`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `cc_list` ;

CREATE TABLE IF NOT EXISTS  `cc_list` (
  `issueId` BIGINT NOT NULL,
  `who` BIGINT NOT NULL,
  INDEX `cclist_issueId_idx` (`issueId` ASC),
  INDEX `cclist_who_idx` (`who` ASC),
  CONSTRAINT `cclist_issueId`
    FOREIGN KEY (`issueId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `cclist_who`
    FOREIGN KEY (`who`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `commit`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `commit` ;

CREATE TABLE IF NOT EXISTS  `commit` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `commitHash` VARCHAR(255) NOT NULL,
  `commitDate` DATETIME NOT NULL,
  `authorDate` DATETIME NOT NULL,
  `authorTimeOffset` INT NULL DEFAULT NULL,
  `authorTimezones` VARCHAR(255) NULL DEFAULT NULL,
  `author` BIGINT NOT NULL,
  `projectId` BIGINT NOT NULL,
  `ChangedFiles` INT NULL DEFAULT NULL,
  `AddedLines` INT NULL DEFAULT NULL,
  `DeletedLines` INT NULL DEFAULT NULL,
  `DiffSize` INT NULL DEFAULT NULL,
  `CmtMsgLines` INT NULL DEFAULT NULL,
  `CmtMsgBytes` INT NULL DEFAULT NULL,
  `NumSignedOffs` INT NULL DEFAULT NULL,
  `NumTags` INT NULL DEFAULT NULL,
  `general` INT NULL DEFAULT NULL,
  `TotalSubsys` INT NULL DEFAULT NULL,
  `Subsys` VARCHAR(45) NULL DEFAULT NULL,
  `inRC` INT NULL DEFAULT NULL,
  `AuthorSubsysSimilarity` FLOAT NULL DEFAULT NULL,
  `AuthorTaggersSimilarity` FLOAT NULL DEFAULT NULL,
  `TaggersSubsysSimilarity` FLOAT NULL DEFAULT NULL,
  `releaseRangeId` BIGINT NULL DEFAULT NULL,
  `description` TEXT NULL,
  `corrective` TINYINT(1) NULL,
  PRIMARY KEY (`id`),
  INDEX `commit_person_idx` (`author` ASC),
  INDEX `commit_project_idx` (`projectId` ASC),
  INDEX `commit_release_end_idx` (`releaseRangeId` ASC),
  CONSTRAINT `commit_person`
    FOREIGN KEY (`author`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commit_project`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commit_release_range`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `commit_communication`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `commit_communication` ;

CREATE TABLE IF NOT EXISTS  `commit_communication` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `commitId` BIGINT NOT NULL,
  `who` BIGINT NOT NULL,
  `communicationType` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `commtcom_commit_idx` (`commitId` ASC),
  INDEX `commitcom_person_idx` (`who` ASC),
  CONSTRAINT `commitcom_commit`
    FOREIGN KEY (`commitId`)
    REFERENCES  `commit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `commitcom_person`
    FOREIGN KEY (`who`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `issue_duplicates`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `issue_duplicates` ;

CREATE TABLE IF NOT EXISTS  `issue_duplicates` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `originalBugId` BIGINT NOT NULL,
  `duplicateBugId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `original_issue_duplicate_idx` (`originalBugId` ASC),
  INDEX `duplicate_issue_duplicate_idx` (`duplicateBugId` ASC),
  CONSTRAINT `original_issue_duplicate`
    FOREIGN KEY (`originalBugId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `duplicate_issue_duplicate`
    FOREIGN KEY (`duplicateBugId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `issue_dependencies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `issue_dependencies` ;

CREATE TABLE IF NOT EXISTS  `issue_dependencies` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `originalIssueId` BIGINT NOT NULL,
  `dependentIssueId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `dependent_original_issue_idx` (`originalIssueId` ASC),
  INDEX `dependent_dependent_issue_idx` (`dependentIssueId` ASC),
  CONSTRAINT `dependent_original_issue`
    FOREIGN KEY (`originalIssueId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `dependent_dependent_issue`
    FOREIGN KEY (`dependentIssueId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `author_commit_stats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `author_commit_stats` ;

CREATE TABLE IF NOT EXISTS  `author_commit_stats` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `authorId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `added` INT NULL DEFAULT NULL,
  `deleted` INT NULL DEFAULT NULL,
  `total` INT NULL DEFAULT NULL,
  `numcommits` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `author_person_key_idx` (`authorId` ASC),
  INDEX `releaseRangeId_key_idx` (`releaseRangeId` ASC),
  CONSTRAINT `author_person_key`
    FOREIGN KEY (`authorId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `releaseRangeId_key`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `plots`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `plots` ;

CREATE TABLE IF NOT EXISTS  `plots` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NULL DEFAULT NULL,
  `labelx` VARCHAR(45) NULL DEFAULT NULL,
  `labely` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `plot_project_ref_idx` (`projectId` ASC),
  INDEX `plot_releaseRangeId_ref_idx` (`releaseRangeId` ASC),
  CONSTRAINT `plot_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `plot_releaseRangeId_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `plot_bin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `plot_bin` ;

CREATE TABLE IF NOT EXISTS  `plot_bin` (
  `plotID` BIGINT NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `data` LONGBLOB NOT NULL,
  INDEX `plot_bin_plot_ref_idx` (`plotID` ASC),
  CONSTRAINT `plot_bin_plot_ref`
    FOREIGN KEY (`plotID`)
    REFERENCES  `plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `cluster`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `cluster` ;

CREATE TABLE IF NOT EXISTS  `cluster` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `clusterNumber` INT NULL DEFAULT NULL,
  `clusterMethod` VARCHAR(45) NULL DEFAULT NULL,
  `dot` BIGINT NULL DEFAULT NULL,
  `svg` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `project_cluster_ref_idx` (`projectId` ASC),
  INDEX `dot_plot_bin_data_idx` (`dot` ASC),
  INDEX `svg_plot_bin_data_ref_idx` (`svg` ASC),
  INDEX `cluster_releaseRange_idx` (`releaseRangeId` ASC),
  CONSTRAINT `project_cluster_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `dot_plot_bin_data`
    FOREIGN KEY (`dot`)
    REFERENCES  `plot_bin` (`plotID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `svg_plot_bin_data_ref`
    FOREIGN KEY (`svg`)
    REFERENCES  `plot_bin` (`plotID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `cluster_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `cluster_user_mapping`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `cluster_user_mapping` ;

CREATE TABLE IF NOT EXISTS  `cluster_user_mapping` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `personId` BIGINT NOT NULL,
  `clusterId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `cluster_cluster_user_ref_idx` (`clusterId` ASC),
  INDEX `person_cluster_user_ref_idx` (`personId` ASC),
  CONSTRAINT `cluster_cluster_user_ref`
    FOREIGN KEY (`clusterId`)
    REFERENCES  `cluster` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `person_cluster_user_ref`
    FOREIGN KEY (`personId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `issue_history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `issue_history` ;

CREATE TABLE IF NOT EXISTS  `issue_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `changeDate` DATETIME NOT NULL,
  `field` VARCHAR(45) NOT NULL,
  `oldValue` VARCHAR(45) NULL DEFAULT NULL,
  `newValue` VARCHAR(45) NULL DEFAULT NULL,
  `who` BIGINT NOT NULL,
  `issueId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `issue_history_issue_map_idx` (`issueId` ASC),
  INDEX `issue_history_person_map_idx` (`who` ASC),
  CONSTRAINT `issue_history_issue_map`
    FOREIGN KEY (`issueId`)
    REFERENCES  `issue` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `issue_history_person_map`
    FOREIGN KEY (`who`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `url_info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `url_info` ;

CREATE TABLE IF NOT EXISTS  `url_info` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `url` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `url_info_project_idx` (`projectId` ASC),
  CONSTRAINT `url_info_project`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `timeseries`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `timeseries` ;

CREATE TABLE IF NOT EXISTS  `timeseries` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `value` DOUBLE NOT NULL,
  `value_scaled` DOUBLE NULL DEFAULT NULL,
  INDEX `plot_time_double_plot_ref_idx` (`plotId` ASC),
  CONSTRAINT `plot_time_double_plot_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES  `plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `freq_subjects`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `freq_subjects` ;

CREATE TABLE IF NOT EXISTS  `freq_subjects` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `subject` TEXT NOT NULL,
  `count` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `freq_subects_project_ref_idx` (`projectId` ASC),
  INDEX `freq_subjects_release_range_ref_idx` (`releaseRangeId` ASC),
  INDEX `freq_subjects_mlId_ref_idx` (`mlId` ASC),
  CONSTRAINT `freq_subects_project_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `freq_subjects_release_range_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `freq_subjects_mlId_ref`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `thread_density`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `thread_density` ;

CREATE TABLE IF NOT EXISTS  `thread_density` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `num` DOUBLE NOT NULL,
  `density` DOUBLE NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `projectId` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `project_thread_density_ref_idx` (`projectId` ASC),
  CONSTRAINT `project_thread_density_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `pagerank`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `pagerank` ;

CREATE TABLE IF NOT EXISTS  `pagerank` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `releaseRangeId` BIGINT NOT NULL,
  `technique` TINYINT NOT NULL,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `pagerank_releaserange_idx` (`releaseRangeId` ASC),
  CONSTRAINT `pagerank_releaserange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table  `pagerank_matrix`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `pagerank_matrix` ;

CREATE TABLE IF NOT EXISTS  `pagerank_matrix` (
  `pageRankId` BIGINT NOT NULL,
  `personId` BIGINT NOT NULL,
  `rankValue` DOUBLE NOT NULL,
  PRIMARY KEY (`pageRankId`, `personId`),
  INDEX `pagerankMatrix_pagerank_idx` (`pageRankId` ASC),
  INDEX `pagerankMatrix_person_idx` (`personId` ASC),
  CONSTRAINT `pagerankMatrix_pagerank`
    FOREIGN KEY (`pageRankId`)
    REFERENCES  `pagerank` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `pagerankMatrix_person`
    FOREIGN KEY (`personId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `edgelist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `edgelist` ;

CREATE TABLE IF NOT EXISTS  `edgelist` (
  `clusterId` BIGINT NOT NULL,
  `fromId` BIGINT NOT NULL,
  `toId` BIGINT NOT NULL,
  `weight` DOUBLE NOT NULL,
  INDEX `edgelist_person_from_idx` (`fromId` ASC),
  INDEX `edgelist_person_to_idx` (`toId` ASC),
  INDEX `edgeList_cluster_idx` (`clusterId` ASC),
  CONSTRAINT `edgelist_person_from`
    FOREIGN KEY (`fromId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `edgeList_person_to`
    FOREIGN KEY (`toId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `edgeList_cluster`
    FOREIGN KEY (`clusterId`)
    REFERENCES  `cluster` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `twomode_edgelist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `twomode_edgelist` ;

CREATE TABLE IF NOT EXISTS  `twomode_edgelist` (
  `releaseRangeId` BIGINT NOT NULL,
  `source` CHAR(7) NOT NULL,
  `mlId` BIGINT NOT NULL,
  `fromVert` BIGINT NOT NULL,
  `toVert` VARCHAR(255) NOT NULL,
  `weight` DOUBLE NOT NULL,
  INDEX `twomode_edgelist_releaseRange_idx` (`releaseRangeId` ASC),
  INDEX `twomode_edgelist_person_idx` (`fromVert` ASC),
  INDEX `twomode_edgelist_mlId_idx` (`mlId` ASC),
  CONSTRAINT `twomode_edgelist_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_edgelist_person`
    FOREIGN KEY (`fromVert`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_edgelist_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `twomode_vertices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `twomode_vertices` ;

CREATE TABLE IF NOT EXISTS  `twomode_vertices` (
  `releaseRangeId` BIGINT NOT NULL,
  `source` CHAR(7) NOT NULL,
  `mlId` BIGINT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `degree` DOUBLE NOT NULL,
  `type` SMALLINT NOT NULL,
  INDEX `twomode_vertices_releaseRange_idx` (`releaseRangeId` ASC),
  INDEX `twomode_vertices_mlId_idx` (`mlId` ASC),
  CONSTRAINT `twomode_vertices_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `twomode_vertices_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `initiate_response`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `initiate_response` ;

CREATE TABLE IF NOT EXISTS  `initiate_response` (
  `releaseRangeId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `personId` BIGINT NOT NULL,
  `source` TINYINT NOT NULL,
  `responses` INT NULL DEFAULT NULL,
  `initiations` INT NULL DEFAULT NULL,
  `responses_received` INT NULL DEFAULT NULL,
  `deg` DOUBLE NULL DEFAULT NULL,
  INDEX `initiate_response_releaseRange_idx` (`releaseRangeId` ASC),
  INDEX `initiate_response_person_idx` (`personId` ASC),
  INDEX `initiate_response_mlId_idx` (`mlId` ASC),
  CONSTRAINT `initiate_response_releaseRange`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `initiate_response_person`
    FOREIGN KEY (`personId`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `initiate_response_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `per_cluster_statistics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `per_cluster_statistics` ;

CREATE TABLE IF NOT EXISTS  `per_cluster_statistics` (
  `projectId` BIGINT NOT NULL,
  `releaseRangeId` BIGINT NOT NULL,
  `clusterId` BIGINT NOT NULL,
  `technique` TINYINT NOT NULL,
  `num_members` INT(11) NOT NULL,
  `added` INT(11) NOT NULL,
  `deleted` INT(11) NOT NULL,
  `total` INT(11) NOT NULL,
  `numcommits` INT(11) NOT NULL,
  `prank_avg` DOUBLE NOT NULL,
  INDEX `fk_per_cluster_statistics_1_idx` (`projectId` ASC),
  INDEX `fk_per_cluster_statistics_1_idx1` (`releaseRangeId` ASC),
  CONSTRAINT `per_cluster_statistics_projectId_ref`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `per_cluster_statistics_rr_ref`
    FOREIGN KEY (`releaseRangeId`)
    REFERENCES  `release_range` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `sloccount_ts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `sloccount_ts` ;

CREATE TABLE IF NOT EXISTS  `sloccount_ts` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `person_months` DOUBLE NOT NULL,
  `total_cost` DOUBLE NOT NULL,
  `schedule_months` DOUBLE NOT NULL,
  `avg_devel` DOUBLE NOT NULL,
  UNIQUE INDEX `time_UNIQUE` (`time` ASC),
  CONSTRAINT `sloccount_ts_plotid_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES  `plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `understand_raw`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `understand_raw` ;

CREATE TABLE IF NOT EXISTS  `understand_raw` (
  `plotId` BIGINT NOT NULL,
  `time` DATETIME NOT NULL,
  `kind` VARCHAR(30) NOT NULL,
  `name` VARCHAR(45) NULL,
  `variable` VARCHAR(45) NOT NULL,
  `value` DOUBLE NOT NULL,
  INDEX `understand_raw_kind_idx` (`kind` ASC),
  INDEX `understand_raw_plotId_idx` (`plotId` ASC),
  CONSTRAINT `understand_raw_id_ref`
    FOREIGN KEY (`plotId`)
    REFERENCES  `plots` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `commit_dependency`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `commit_dependency` ;

CREATE TABLE IF NOT EXISTS  `commit_dependency` (
  `id` BIGINT NULL AUTO_INCREMENT,
  `commitId` BIGINT NOT NULL,
  `file` VARCHAR(255) NOT NULL,
  `entityId` VARCHAR(255) NOT NULL,
  `entityType` VARCHAR(100) NOT NULL,
  `size` INT NULL,
  `impl` MEDIUMTEXT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_1_idx` (`commitId` ASC),
  CONSTRAINT `fk_commit_dependency`
    FOREIGN KEY (`commitId`)
    REFERENCES  `commit` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- -----------------------------------------------------
-- Table  `mail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS  `mail` ;

CREATE TABLE IF NOT EXISTS  `mail` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `projectId` BIGINT NOT NULL,
  `threadId` BIGINT NOT NULL,
  `mlId` BIGINT NOT NULL,
  `author` BIGINT NOT NULL,
  `subject` VARCHAR(255) NULL DEFAULT NULL,
  `creationDate` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `mail_author_idx` (`author` ASC),
  INDEX `mail_projectId_idx` (`projectId` ASC),
  INDEX `mail_mlId_idx` (`mlId` ASC),
  INDEX `mail_comp1_idx` (`mlId` ASC, `projectId` ASC, `creationDate` ASC),
  CONSTRAINT `mail_author`
    FOREIGN KEY (`author`)
    REFERENCES  `person` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mail_projectId`
    FOREIGN KEY (`projectId`)
    REFERENCES  `project` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `mail_mlId`
    FOREIGN KEY (`mlId`)
    REFERENCES  `mailing_list` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- procedure update_per_cluster_statistics
-- -----------------------------------------------------

USE `codeface`;
DROP procedure IF EXISTS  `update_per_cluster_statistics`;

DELIMITER $$
CREATE PROCEDURE update_per_cluster_statistics ()
BEGIN
	TRUNCATE per_cluster_statistics;
	INSERT INTO per_cluster_statistics SELECT * FROM per_cluster_statistics_view;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View  `revisions_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS  `revisions_view` ;

USE `codeface`;
CREATE  OR REPLACE VIEW  `revisions_view` AS
SELECT 
	p.id as projectId,
	rr.id as releaseRangeID,
	rt_s.date as date_start, 
	rt_e.date as date_end, 
	rt_rs.date as date_rc_start, 
	rt_s.tag as tag, 
	concat(rt_s.tag,'-',rt_e.tag) as cycle
FROM 
	release_range rr JOIN release_timeline rt_s ON rr.releaseStartId = rt_s.id
	JOIN release_timeline rt_e ON rr.releaseEndId = rt_e.id
	LEFT JOIN release_timeline rt_rs ON rr.releaseRCStartId = rt_rs.id
	JOIN project p ON rr.projectId = p.id
order by rr.id asc;

-- -----------------------------------------------------
-- View  `author_commit_stats_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS author_commit_stats_view ;

USE `codeface`;
CREATE  OR REPLACE VIEW author_commit_stats_view AS
SELECT 
	p.name as Name, 
	s.authorId as ID, 
	s.releaseRangeId, 
	sum(s.added) as added, 
	sum(s.deleted) as deleted, 
	sum(s.total) as total, 
	sum(s.numcommits) as numcommits
FROM author_commit_stats s join person p on p.id = s.authorId
WHERE 
s.authorId IN 
	(	select distinct(authorId) 
		FROM author_commit_stats)
GROUP BY s.authorId, p.name, s.releaseRangeId;

-- -----------------------------------------------------
-- View  `per_person_cluster_statistics_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS per_person_cluster_statistics_view ;

USE `codeface`;
CREATE  OR REPLACE VIEW per_person_cluster_statistics_view AS
select 
    rr.projectId as projectId,
    rr.id as releaseRangeId,
    c.id as clusterId,
    p.id as personId,
	pr.technique as technique,
	prm.rankValue as rankValue,
    sum(acs.added) as added,
    sum(acs.deleted) as deleted,
    sum(acs.total) as total,
    sum(acs.numcommits) as numcommits
from release_range rr INNER JOIN (cluster c, cluster_user_mapping cum, person p, author_commit_stats acs, pagerank pr, pagerank_matrix prm)
	ON (rr.id = c.releaseRangeId
		AND c.id = cum.clusterId
        AND cum.personId = p.id
		AND rr.id = acs.releaseRangeId
		AND p.id = acs.authorId
		AND rr.id = pr.releaseRangeID
		AND pr.id = prm.pageRankId
		AND p.id = prm.personId)
group by rr.projectId , rr.id , c.id , p.id, pr.technique, prm.rankValue;

-- -----------------------------------------------------
-- View  `cluster_user_pagerank_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS cluster_user_pagerank_view ;

USE `codeface`;
CREATE  OR REPLACE VIEW cluster_user_pagerank_view AS
SELECT
	cum.id, 
	cum.personId,
	cum.clusterId AS clusterId,
	pr.technique,
	prm.rankValue
FROM
	cluster_user_mapping cum
	INNER JOIN (cluster c, pagerank_matrix prm, pagerank pr)
	ON (cum.personId = prm.personId AND
	    cum.clusterId = c.id AND
	    prm.pageRankId = pr.id AND
	    c.releaseRangeId = pr.releaseRangeId);

-- -----------------------------------------------------
-- View  `per_cluster_statistics_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS per_cluster_statistics_view ;

USE `codeface`;
CREATE OR REPLACE VIEW per_cluster_statistics_view AS
select 
    rr.projectId as projectId,
    rr.id as releaseRangeId,
    c.id as clusterId,
	pr.technique,
    count(p.id) as num_members,
    sum(acs.added) as added,
    sum(acs.deleted) as deleted,
    sum(acs.total) as total,
    sum(acs.numcommits) as numcommits,
	avg(prm.rankValue) as prank_avg
from release_range rr INNER JOIN (cluster c, cluster_user_mapping cum, person p, author_commit_stats acs, pagerank pr, pagerank_matrix prm)
	ON (rr.id = c.releaseRangeId
		AND c.id = cum.clusterId
        AND cum.personId = p.id
		AND rr.id = acs.releaseRangeId
		AND p.id = acs.authorId
		AND rr.id = pr.releaseRangeID
		AND pr.id = prm.pageRankId
		AND p.id = prm.personId)
group by rr.projectId , rr.id , c.id, pr.technique;

-- -----------------------------------------------------
-- View  `pagerank_view`
-- -----------------------------------------------------
DROP VIEW IF EXISTS pagerank_view ;

USE `codeface`;
CREATE  OR REPLACE VIEW pagerank_view AS
SELECT
	prm.pageRankId as pageRankId,
	p.id as authorId,
	p.name AS name,
        prm.rankValue AS rankValue
FROM pagerank_matrix prm JOIN person p ON p.id=prm.personId;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
