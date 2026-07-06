-- =====================================================================
-- 05_routines.sql
-- =====================================================================
USE `greengrant`;

-- ---------------------------------------------------------------------
-- 1. STORED FUNCTION: fn_calculate_proposal_average_score
-- Nghiệp vụ: Trả về điểm trung bình tổng hợp của một đề xuất (Thang điểm 10)
-- ---------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION `greengrant`.`fn_calculate_proposal_average_score`(p_proposal_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg_score DECIMAL(4,2);
    
    SELECT AVG((score_relevance + score_clarity + score_methodology + score_impact) / 4.0)
    INTO v_avg_score
    FROM review
    WHERE assignment_proposal_id = p_proposal_id;
    
    RETURN COALESCE(v_avg_score, 0.00);
END$$
DELIMITER ;

-- Minh chứng cách gọi Function trong một SELECT
SELECT proposal_id, title, fn_calculate_proposal_average_score(proposal_id) AS `Điểm đánh giá hệ thống`
FROM proposal;


-- ---------------------------------------------------------------------
-- 2. STORED PROCEDURE: sp_assign_reviewer_to_proposal
-- Nghiệp vụ: Thực hiện phân công chuyên gia phản biện vào đề xuất an toàn
-- Có cơ chế bắt lỗi Validation đầu vào và kiểm soát toàn vẹn bằng Transaction
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS greengrant.sp_assign_reviewer_to_proposal;
DELIMITER $$
CREATE PROCEDURE `greengrant`.`sp_assign_reviewer_to_proposal`(
    IN p_proposal_id INT,
    IN p_reviewer_id INT,
    IN p_date_sent DATE
)
BEGIN
    DECLARE v_proposal_exists INT;
    DECLARE v_reviewer_exists INT;
    DECLARE v_status ENUM('received','rejected','under review','accepted','scheduled','published');
    
    -- Khởi tạo cơ chế bắt lỗi hệ thống ngoại lệ
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Giao dịch thất bại: Lỗi cơ sở dữ liệu hệ thống, tiến trình đã rollback hoàn toàn.';
    END;

    START TRANSACTION;
    
    -- Kiểm tra sự tồn tại của hồ sơ đề xuất và chuyên gia
    SELECT COUNT(*) INTO v_proposal_exists FROM proposal WHERE proposal_id = p_proposal_id;
    SELECT COUNT(*) INTO v_reviewer_exists FROM reviewer WHERE reviewer_id = p_reviewer_id;
    
    IF v_proposal_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Mã hồ sơ đề xuất (proposal_id) không tồn tại trên hệ thống.';
    END IF;
    
    IF v_reviewer_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Mã chuyên gia phản biện (reviewer_id) không tồn tại trên hệ thống.';
    END IF;
    
    -- Kiểm tra trạng thái hồ sơ đề xuất xem có được phép phân công phản biện hay không
    SELECT status INTO v_status FROM proposal WHERE proposal_id = p_proposal_id;
    IF v_status NOT IN ('received', 'under review') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi nghiệp vụ: Chỉ những đề xuất ở trạng thái received hoặc under review mới được phép phân công.';
    END IF;

    -- Thực hiện chèn thông tin phân công
    INSERT INTO assignment (proposal_id, reviewer_id, date_sent)
    VALUES (p_proposal_id, p_reviewer_id, p_date_sent);
    
    COMMIT;
END$$
DELIMITER;

- 3. STORED PROCEDURE: sp_reject_proposal
-- Nghiệp vụ: Điều phối viên từ chối đề xuất không hợp lệ ở vòng sơ loại
DROP PROCEDURE IF EXISTS greengrant.sp_reject_proposal;
 
DELIMITER $$
CREATE PROCEDURE greengrant.sp_reject_proposal(
	IN p_proposal_id INT
)
BEGIN
	-- Chỉ cập nhật trạng thái thành rejected đối với hồ sơ đang ở mức received
	UPDATE proposal
	SET status = 'rejected'
	WHERE proposal_id = p_proposal_id AND status = 'received';
END$$
DELIMITER ;
 
-- =======================================================
-- Lệnh gọi thực thi (Kiểm thử)
-- =======================================================
CALL greengrant.sp_reject_proposal(4);
 
SELECT proposal_id, title, status, date_received
FROM proposal
WHERE proposal_id = 4;
