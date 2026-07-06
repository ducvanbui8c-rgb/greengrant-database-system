-- =====================================================================
-- 01_schema.sql
-- =====================================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE,
    SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `greengrant` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `greengrant`;

-- ---------------------------------------------------------------------
-- field
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`field` (
  `field_id`    VARCHAR(10)  NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  CONSTRAINT `pk_field` PRIMARY KEY (`field_id`),
  CONSTRAINT `ak_field_description` UNIQUE (`description`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- issue
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`issue` (
  `issue_id`      INT  NOT NULL AUTO_INCREMENT,
  `season`        VARCHAR(20) NOT NULL,
  `year`          YEAR NOT NULL,
  `volume`        INT  NOT NULL,
  `issue_number`  INT  NOT NULL,
  `release_date`  DATE NULL DEFAULT NULL,
  CONSTRAINT `pk_issue` PRIMARY KEY (`issue_id`),
  CONSTRAINT `ak_issue_vol_num` UNIQUE (`volume`, `issue_number`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- applicant
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`applicant` (
  `applicant_id` INT NOT NULL AUTO_INCREMENT,
  `first_name`   VARCHAR(100) NOT NULL,
  `last_name`    VARCHAR(100) NOT NULL,
  `address`      TEXT NOT NULL,
  `email`        VARCHAR(255) NOT NULL,
  `organization` VARCHAR(255) NOT NULL,
  CONSTRAINT `pk_applicant` PRIMARY KEY (`applicant_id`),
  CONSTRAINT `ak_applicant_email` UNIQUE (`email`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- reviewer
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`reviewer` (
  `reviewer_id`  INT NOT NULL AUTO_INCREMENT,
  `first_name`   VARCHAR(100) NOT NULL,
  `last_name`    VARCHAR(100) NOT NULL,
  `email`        VARCHAR(255) NOT NULL,
  `organization` VARCHAR(255) NOT NULL,
  CONSTRAINT `pk_reviewer` PRIMARY KEY (`reviewer_id`),
  CONSTRAINT `ak_reviewer_email` UNIQUE (`email`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- proposal
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`proposal` (
  `proposal_id`   INT NOT NULL AUTO_INCREMENT,
  `title`         VARCHAR(500) NOT NULL,
  `date_received` DATE NOT NULL,
  `status`        ENUM('received','rejected','under review','accepted','scheduled','published')
                  NOT NULL DEFAULT 'received',
  `date_accepted` DATE NULL,
  `page_count`    INT NULL,
  CONSTRAINT `pk_proposal` PRIMARY KEY (`proposal_id`),
  CONSTRAINT `chk_proposal_accepted_date` CHECK (
        (`status` IN ('accepted','scheduled','published') AND `date_accepted` IS NOT NULL)
     OR (`status` NOT IN ('accepted','scheduled','published') AND `date_accepted` IS NULL)
  ),
  CONSTRAINT `chk_proposal_page_count` CHECK (`page_count` IS NULL OR `page_count` >= 1)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- proposal_applicant
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`proposal_applicant` (
  `proposal_id`   INT NOT NULL,
  `applicant_id`  INT NOT NULL,
  `display_order` INT NOT NULL,
  CONSTRAINT `pk_proposal_applicant` PRIMARY KEY (`proposal_id`, `applicant_id`),
  CONSTRAINT `ak_pa_order` UNIQUE (`proposal_id`, `display_order`),
  CONSTRAINT `fk_pa_proposal` FOREIGN KEY (`proposal_id`)
      REFERENCES `greengrant`.`proposal` (`proposal_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pa_applicant` FOREIGN KEY (`applicant_id`)
      REFERENCES `greengrant`.`applicant` (`applicant_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- reviewer_field
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`reviewer_field` (
  `reviewer_id` INT NOT NULL,
  `field_id`    VARCHAR(10) NOT NULL,
  CONSTRAINT `pk_reviewer_field` PRIMARY KEY (`reviewer_id`, `field_id`),
  CONSTRAINT `fk_rf_reviewer` FOREIGN KEY (`reviewer_id`)
      REFERENCES `greengrant`.`reviewer` (`reviewer_id`)
      ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rf_field` FOREIGN KEY (`field_id`)
      REFERENCES `greengrant`.`field` (`field_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- assignment
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`assignment` (
  `proposal_id` INT NOT NULL,
  `reviewer_id` INT NOT NULL,
  `date_sent`   DATE NOT NULL,
  CONSTRAINT `pk_assignment` PRIMARY KEY (`proposal_id`, `reviewer_id`),
  CONSTRAINT `fk_asgn_proposal` FOREIGN KEY (`proposal_id`)
      REFERENCES `greengrant`.`proposal` (`proposal_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_asgn_reviewer` FOREIGN KEY (`reviewer_id`)
      REFERENCES `greengrant`.`reviewer` (`reviewer_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- review
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`review` (
  `review_id`               INT NOT NULL AUTO_INCREMENT,
  `assignment_proposal_id`  INT NOT NULL,
  `assignment_reviewer_id`  INT NOT NULL,
  `score_relevance`         TINYINT NOT NULL,
  `score_clarity`           TINYINT NOT NULL,
  `score_methodology`       TINYINT NOT NULL,
  `score_impact`            TINYINT NOT NULL,
  `recommendation`          ENUM('accept','reject') NOT NULL,
  `date_received`           DATE NOT NULL,
  CONSTRAINT `pk_review` PRIMARY KEY (`review_id`),
  CONSTRAINT `ak_review_assignment` UNIQUE (`assignment_proposal_id`, `assignment_reviewer_id`),
  CONSTRAINT `fk_review_assignment` FOREIGN KEY (`assignment_proposal_id`, `assignment_reviewer_id`)
      REFERENCES `greengrant`.`assignment` (`proposal_id`, `reviewer_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_score_relevance`   CHECK (`score_relevance`   BETWEEN 1 AND 10),
  CONSTRAINT `ck_score_clarity`     CHECK (`score_clarity`     BETWEEN 1 AND 10),
  CONSTRAINT `ck_score_methodology` CHECK (`score_methodology` BETWEEN 1 AND 10),
  CONSTRAINT `ck_score_impact`      CHECK (`score_impact`      BETWEEN 1 AND 10)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- issue_proposal
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `greengrant`.`issue_proposal` (
  `issue_id`          INT NOT NULL,
  `proposal_id`       INT NOT NULL,
  `appearance_order`  INT NOT NULL,
  `start_page`        INT NOT NULL,
  CONSTRAINT `pk_issue_proposal` PRIMARY KEY (`issue_id`, `proposal_id`),
  CONSTRAINT `ak_ip_order` UNIQUE (`issue_id`, `appearance_order`),
  CONSTRAINT `ak_ip_proposal` UNIQUE (`proposal_id`),
  CONSTRAINT `fk_ip_issue` FOREIGN KEY (`issue_id`)
      REFERENCES `greengrant`.`issue` (`issue_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_ip_proposal` FOREIGN KEY (`proposal_id`)
      REFERENCES `greengrant`.`proposal` (`proposal_id`)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_ip_order` CHECK (`appearance_order` >= 1),
  CONSTRAINT `chk_ip_start_page` CHECK (`start_page` >= 1)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
