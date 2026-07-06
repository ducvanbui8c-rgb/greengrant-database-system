-- =====================================================================
-- 07_indexes_explain.sql
-- =====================================================================
USE `greengrant`;

-- Thiết lập Chỉ mục thứ cấp phục vụ Workload truy vấn và tìm kiếm đề xuất
CREATE INDEX `idx_proposal_status_date` ON `greengrant`.`proposal` (`status`, `date_received`);

-- Thiết lập Chỉ mục thứ cấp phục vụ Workload thống kê của chuyên gia phản biện
CREATE INDEX `idx_review_score_composite` ON `greengrant`.`review` (`score_relevance`, `score_clarity`, `score_methodology`, `score_impact`);

-- Chạy EXPLAIN phân tích hành vi của hệ thống trước và sau khi tối ưu hóa
EXPLAIN SELECT proposal_id, title, date_received 
FROM proposal 
WHERE status = 'received' 
ORDER BY date_received ASC;