-- =====================================================================
-- 06_triggers_events.sql
-- =====================================================================
USE `greengrant`;

-- 1. Trigger kiểm tra điều kiện chèn vào Issue_Proposal (BR-10)
DELIMITER $$
CREATE TRIGGER `greengrant`.`trg_ip_only_accepted`
BEFORE INSERT ON `greengrant`.`issue_proposal`
FOR EACH ROW
BEGIN
    DECLARE p_status ENUM('received','rejected','under review','accepted','scheduled','published');
    SELECT status INTO p_status FROM proposal WHERE proposal_id = NEW.proposal_id;
    
    IF p_status IS NULL OR p_status != 'accepted' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Chỉ đề xuất có trạng thái accepted mới có thể xếp vào đợt công bố.';
    END IF;
END$$

-- 2. Trigger tự động chuyển trạng thái đề xuất sang scheduled (BR-13)
CREATE TRIGGER `greengrant`.`trg_ip_set_scheduled`
AFTER INSERT ON `greengrant`.`issue_proposal`
FOR EACH ROW
BEGIN
    UPDATE proposal SET status = 'scheduled'
    WHERE proposal_id = NEW.proposal_id;
END$$

-- 3. Trigger tự động cập nhật published hàng loạt khi đợt công bố phát hành (BR-13)
CREATE TRIGGER `greengrant`.`trg_issue_publish`
AFTER UPDATE ON `greengrant`.`issue`
FOR EACH ROW
BEGIN
    IF NEW.release_date IS NOT NULL AND OLD.release_date IS NULL THEN
        UPDATE proposal p
        JOIN issue_proposal ip ON p.proposal_id = ip.proposal_id
        SET p.status = 'published'
        WHERE ip.issue_id = NEW.issue_id;
    END IF;
END$$

-- 4. Trigger bảo toàn quy tắc chuyên gia luôn có ít nhất 1 lĩnh vực (BR-05)
CREATE TRIGGER `greengrant`.`trg_reviewer_field_min_one`
AFTER DELETE ON `greengrant`.`reviewer_field`
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM reviewer_field
    WHERE reviewer_id = OLD.reviewer_id;
    IF cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi toàn vẹn: Chuyên gia phải có ít nhất 1 lĩnh vực chuyên môn.';
    END IF;
END$$

-- 5. Trigger dọn dẹp dữ liệu người nộp mồ côi (BR-04)
CREATE TRIGGER `greengrant`.`trg_applicant_min_one_proposal`
AFTER DELETE ON `greengrant`.`proposal_applicant`
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM proposal_applicant
    WHERE applicant_id = OLD.applicant_id;
    IF cnt = 0 THEN
        DELETE FROM applicant WHERE applicant_id = OLD.applicant_id;
    END IF;
END$$
DELIMITER ;