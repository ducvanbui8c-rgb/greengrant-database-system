-- =====================================================================
-- 04_views.sql
-- =====================================================================
USE `greengrant`;

-- VIEW 1: vw_proposal_review_summary (View tổng hợp kết quả phản biện phục vụ Hội đồng)
-- Use case: Giúp hội đồng xem nhanh điểm trung bình của từng tiêu chí và khuyến nghị tổng hợp mà không cần JOIN phức tạp.
CREATE OR REPLACE VIEW vw_proposal_review_summary AS
SELECT 
    p.proposal_id AS `Mã đề xuất`,
    p.title AS `Tiêu đề`,
    p.status AS `Trạng thái`,
    COUNT(r.review_id) AS `Số phiếu phản biện đã nộp`,
    ROUND(AVG(r.score_relevance), 2) AS `Điểm trung bình cấp thiết`,
    ROUND(AVG(r.score_clarity), 2) AS `Điểm trung bình mạch lạc`,
    ROUND(AVG(r.score_methodology), 2) AS `Điểm trung bình phương pháp`,
    ROUND(AVG(r.score_impact), 2) AS `Điểm trung bình tác động`,
    SUM(CASE WHEN r.recommendation = 'accept' THEN 1 ELSE 0 END) AS `Số phiếu đồng ý`,
    SUM(CASE WHEN r.recommendation = 'reject' THEN 1 ELSE 0 END) AS `Số phiếu từ chối`
FROM proposal p
LEFT JOIN review r ON p.proposal_id = r.assignment_proposal_id
GROUP BY p.proposal_id, p.title, p.status;

-- Kiểm tra View 1
SELECT * FROM vw_proposal_review_summary;


-- VIEW 2: vw_issue_publication_layout (View phục vụ ban biên tập và in ấn số tạp chí)
-- Use case: Giúp người công bố theo dõi bố cục sắp xếp của các bài nghiên cứu trong từng đợt công bố.
CREATE OR REPLACE VIEW vw_issue_publication_layout AS
SELECT 
    i.issue_id AS `Mã đợt công bố`,
    CONCAT(i.season, ' - ', i.year) AS `Kỳ xuất bản`,
    i.volume AS `Tập`,
    i.issue_number AS `Số`,
    ip.appearance_order AS `Thứ tự mục lục`,
    p.proposal_id AS `Mã đề xuất`,
    p.title AS `Tiêu đề bài viết`,
    ip.start_page AS `Trang bắt đầu`,
    p.page_count AS `Tổng số trang`,
    (ip.start_page + p.page_count - 1) AS `Trang kết thúc`
FROM issue_proposal ip
JOIN issue i ON ip.issue_id = i.issue_id
JOIN proposal p ON ip.proposal_id = p.proposal_id
ORDER BY i.year DESC, i.volume, i.issue_number, ip.appearance_order;

-- Kiểm tra View 2
SELECT * FROM vw_issue_publication_layout;