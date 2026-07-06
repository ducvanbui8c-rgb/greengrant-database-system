-- =====================================================================
-- 09_tests.sql
-- Đề tài : GreenGrant Proposal Review Board
-- Mục đích: Kiểm thử tính đúng đắn của Stored Procedure, CHECK
--           Constraint và Trigger trong môi trường lab
-- =====================================================================

USE greengrant;

-- =====================================================================
-- TC-01 | Ca kiểm thử tích cực 1 (Positive Test)
-- ---------------------------------------------------------------------
-- Tên       : Phân công reviewer hợp lệ cho đề xuất hợp lệ
-- Mục đích  : Xác nhận Stored Procedure sp_assign_reviewer_to_proposal
--             hoạt động đúng khi nhận đầu vào hợp lệ — tạo thành công
--             1 bản ghi trong bảng assignment và cập nhật status của
--             proposal sang 'under review' (nếu đủ 3 reviewer).
-- Thao tác  : Gọi SP với proposal_id = 4, reviewer_id = 4, date hôm nay
-- Kết quả   : Query OK — 1 row affected; bảng assignment có thêm 1 dòng
--             (proposal_id=4, reviewer_id=4); không có lỗi nào được ném
-- =====================================================================

-- Bước 1: Gọi Stored Procedure với tham số hợp lệ
CALL sp_assign_reviewer_to_proposal(4, 4, CURDATE());

-- Bước 2: Xác nhận bản ghi đã được tạo trong bảng assignment
SELECT
    proposal_id,
    reviewer_id,
    date_sent
FROM assignment
WHERE proposal_id = 4
  AND reviewer_id = 4;

-- Bước 3: Kiểm tra trạng thái hiện tại của proposal_id = 4
SELECT
    proposal_id,
    title,
    status
FROM proposal
WHERE proposal_id = 4;

-- =====================================================================
-- TC-02 | Ca kiểm thử tiêu cực 1 (Negative Test — Ràng buộc miền)
-- ---------------------------------------------------------------------
-- Tên       : Vi phạm CHECK constraint trên cột score_relevance
-- Mục đích  : Xác nhận ràng buộc CHECK (score_relevance BETWEEN 1 AND 10)
--             hoạt động đúng — từ chối giá trị nằm ngoài miền cho phép
-- Thao tác  : INSERT 1 dòng vào bảng review với score_relevance = 11
--             (vượt quá giới hạn trên là 10)
-- Kết quả   : Lệnh bị từ chối với Error Code 3819
--             "Check constraint 'ck_score_relevance' is violated"
--             Không có dòng nào được thêm vào bảng review
-- =====================================================================
USE greengrant;
-- Lệnh INSERT cố tình vi phạm CHECK constraint:
INSERT INTO review (
    assignment_proposal_id,
    assignment_reviewer_id,
    score_relevance,
    score_clarity,
    score_methodology,
    score_impact,
    recommendation,
    date_received
)
VALUES (
    4,      -- assignment_proposal_id (proposal đã được assign ở TC-01)
    4,      -- assignment_reviewer_id
    11,     -- ← GIÁ TRỊ VI PHẠM: vượt quá giới hạn BETWEEN 1 AND 10
    8,
    7,
    9,
    'accept',
    CURDATE()
);

-- Kỳ vọng: Lệnh trên KHÔNG chạy được.
-- Câu SELECT dưới đây phải trả về 0 dòng (không có review nào được tạo):
SELECT COUNT(*) AS so_dong_bi_insert
FROM review
WHERE assignment_proposal_id = 4
  AND assignment_reviewer_id = 4;

-- =====================================================================
-- TC-03 | Ca kiểm thử tiêu cực 2 (Negative Test — Lỗi logic thủ tục)
-- ---------------------------------------------------------------------
-- Tên       : Gọi Stored Procedure với proposal_id không tồn tại
-- Mục đích  : Xác nhận SIGNAL SQLSTATE '45000' bên trong SP hoạt động
--             đúng — phát hiện proposal_id giả và ROLLBACK toàn bộ
--             transaction, không để dữ liệu rác lọt vào bảng assignment
-- Thao tác  : Gọi SP với p_proposal_id = 999999 (không tồn tại trong DB)
-- Kết quả   : Lệnh bị từ chối với Error Code 1644
--             Message: "Proposal ID không tồn tại" (hoặc tương tự)
--             Bảng assignment KHÔNG có thêm dòng nào với proposal_id=999999
-- =====================================================================
USE greengrant;
-- Gọi SP với proposal_id không tồn tại:
CALL sp_assign_reviewer_to_proposal(999999, 4, CURDATE());

-- Kỳ vọng: Lệnh trên KHÔNG chạy được, SP ném lỗi SIGNAL 45000.
-- Câu SELECT dưới đây phải trả về 0 dòng:
SELECT COUNT(*) AS so_dong_rac
FROM assignment
WHERE proposal_id = 999999;

-- =====================================================================
-- TC-04 | Ca kiểm thử tiêu cực 3 (Negative Test — Lỗi Trigger)
-- ---------------------------------------------------------------------
-- Tên       : Trigger chặn xếp đề xuất chưa được chấp nhận vào đợt
-- Mục đích  : Xác nhận Trigger trg_ip_only_accepted hoạt động đúng —
--             phát hiện proposal_id = 4 đang ở trạng thái 'received'
--             (chưa phải 'accepted') và từ chối INSERT vào issue_proposal
-- Thao tác  : INSERT proposal_id = 4 vào issue_proposal với issue_id = 1
-- Kết quả   : Lệnh bị từ chối với Error Code 1644
--             Message: "Chỉ đề xuất accepted mới có thể xếp vào đợt
--             công bố" (hoặc tương tự tùy nội dung SIGNAL trong Trigger)
--             Bảng issue_proposal KHÔNG có thêm dòng nào
-- =====================================================================
USE greengrant;
-- Xác nhận trạng thái hiện tại của proposal_id = 4 trước khi thử:
SELECT proposal_id, title, status
FROM proposal
WHERE proposal_id = 4;
-- Kỳ vọng cột status: 'received' (hoặc 'under review' nếu TC-01 đã
-- đủ 3 reviewer) — trong mọi trường hợp đều CHƯA phải 'accepted'

-- Lệnh INSERT cố tình vi phạm điều kiện của Trigger:
INSERT INTO issue_proposal (
    issue_id,
    proposal_id,
    appearance_order,
    start_page
)
VALUES (
    1,   -- issue_id bất kỳ đang tồn tại trong bảng issue
    4,   -- ← proposal_id = 4 đang ở trạng thái chưa được accepted
    99,  -- appearance_order tạm
    999  -- start_page tạm
);

-- Kỳ vọng: Lệnh trên KHÔNG chạy được, Trigger ném lỗi SIGNAL 45000.
-- Câu SELECT dưới đây phải trả về 0 dòng:
SELECT COUNT(*) AS so_dong_bi_insert
FROM issue_proposal
WHERE proposal_id = 4;