-- ============================================================
-- File: 03_queries.sql
-- GreenGrant Proposal Review Board
-- Gói truy vấn nghiệp vụ Q01 – Q08
-- ============================================================

USE greengrant;

-- ----------------------------------------------------------
-- Q01: Filter + ORDER — Danh sách đề xuất đang chờ xét duyệt
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Hội đồng cần biết những đề xuất nào còn ở trạng thái
--   'received' (chưa xử lý), sắp xếp theo ngày nhận cũ nhất
--   lên đầu để ưu tiên giải quyết.
-- Input: Không (lấy toàn bộ)
-- Kỹ thuật: WHERE filter trên ENUM status + ORDER BY ASC
-- Ý nghĩa kết quả: Danh sách hàng đợi cần điều phối viên xử lý

SELECT
    proposal_id,
    title,
    date_received,
    status,
    DATEDIFF(CURDATE(), date_received) AS days_waiting
FROM Proposal
WHERE status = 'received'
ORDER BY date_received ASC;


-- ----------------------------------------------------------
-- Q02: INNER JOIN 3 bảng — Bảng điểm của từng đề xuất
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Lãnh đạo hội đồng cần xem tổng hợp: mỗi đề xuất, do
--   applicant nào đứng đầu (display_order = 1) gửi, và
--   điểm trung bình tổng hợp từ các reviewer là bao nhiêu?
-- Input: Không
-- Kỹ thuật: INNER JOIN Proposal → Proposal_Applicant → Applicant
--           + JOIN Assignment → Review, AVG() aggregation
-- Ý nghĩa kết quả: Bảng tóm tắt hồ sơ xét duyệt

SELECT
    p.proposal_id,
    p.title,
    p.status,
    CONCAT(a.first_name, ' ', a.last_name)  AS lead_applicant,
    a.organization,
    ROUND(AVG((r.score_relevance + r.score_clarity +
               r.score_methodology + r.score_impact) / 4.0), 2)
                                            AS avg_overall_score
FROM Proposal p
INNER JOIN Proposal_Applicant pa
        ON p.proposal_id = pa.proposal_id
       AND pa.display_order = 1
INNER JOIN Applicant a
        ON pa.applicant_id = a.applicant_id
INNER JOIN Assignment asgn
        ON p.proposal_id  = asgn.proposal_id
INNER JOIN Review r
        ON asgn.proposal_id  = r.assignment_proposal_id
       AND asgn.reviewer_id  = r.assignment_reviewer_id
GROUP BY
    p.proposal_id, p.title, p.status,
    lead_applicant, a.organization
ORDER BY avg_overall_score DESC;


-- ----------------------------------------------------------
-- Q03: LEFT JOIN — Reviewer chưa được phân công đề xuất nào
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Điều phối viên muốn biết reviewer nào chưa tham gia
--   bất kỳ vòng xét duyệt nào (thường là reviewer mới
--   hoặc ít được giao việc) để cân bằng tải công việc.
-- Input: Không
-- Kỹ thuật: LEFT JOIN Reviewer ← Assignment, lọc NULL
-- Ý nghĩa kết quả: Danh sách reviewer "rảnh" cần phân công thêm

SELECT
    rv.reviewer_id,
    CONCAT(rv.first_name, ' ', rv.last_name) AS reviewer_name,
    rv.email,
    rv.organization,
    GROUP_CONCAT(f.description ORDER BY f.field_id SEPARATOR ', ')
                                             AS fields_of_expertise
FROM Reviewer rv
LEFT JOIN Assignment asgn
       ON rv.reviewer_id = asgn.reviewer_id
LEFT JOIN Reviewer_Field rf
       ON rv.reviewer_id = rf.reviewer_id
LEFT JOIN Field f
       ON rf.field_id    = f.field_id
WHERE asgn.reviewer_id IS NULL
GROUP BY
    rv.reviewer_id, reviewer_name, rv.email, rv.organization
ORDER BY rv.last_name, rv.first_name;


-- ----------------------------------------------------------
-- Q04: GROUP BY + HAVING — Đề xuất có điểm trung bình cao
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Ban xét duyệt muốn lọc ra những đề xuất có chất lượng
--   phản biện cao (điểm trung bình tổng hợp ≥ 7.5) để ưu
--   tiên ra quyết định 'accepted' sớm.
-- Input: Ngưỡng điểm (hard-code 7.5 — có thể đổi thành param)
-- Kỹ thuật: GROUP BY proposal + HAVING AVG(tổng 4 tiêu chí) ≥ 7.5
-- Ý nghĩa kết quả: Shortlist đề xuất đủ điều kiện chấp nhận

SELECT
    p.proposal_id,
    p.title,
    p.status,
    COUNT(DISTINCT r.review_id)   AS total_reviews,
    ROUND(AVG(r.score_relevance),   2) AS avg_relevance,
    ROUND(AVG(r.score_clarity),     2) AS avg_clarity,
    ROUND(AVG(r.score_methodology), 2) AS avg_methodology,
    ROUND(AVG(r.score_impact),      2) AS avg_impact,
    ROUND(AVG((r.score_relevance + r.score_clarity +
               r.score_methodology + r.score_impact) / 4.0), 2)
                                       AS avg_overall
FROM Proposal p
INNER JOIN Assignment asgn ON p.proposal_id = asgn.proposal_id
INNER JOIN Review r
        ON asgn.proposal_id = r.assignment_proposal_id
       AND asgn.reviewer_id = r.assignment_reviewer_id
GROUP BY p.proposal_id, p.title, p.status
HAVING avg_overall >= 7.5
ORDER BY avg_overall DESC;


-- ----------------------------------------------------------
-- Q05: EXISTS — Applicant chưa từng có đề xuất được 'accepted'
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Phòng hỗ trợ muốn liên hệ khuyến khích những applicant
--   chưa có đề xuất nào được chấp nhận, gợi ý họ cải thiện
--   và tái nộp.
-- Input: Không
-- Kỹ thuật: NOT EXISTS subquery kiểm tra trạng thái accepted
-- Ý nghĩa kết quả: Danh sách applicant cần được tư vấn thêm

SELECT
    a.applicant_id,
    CONCAT(a.first_name, ' ', a.last_name) AS applicant_name,
    a.email,
    a.organization,
    COUNT(pa.proposal_id) AS total_proposals_submitted
FROM Applicant a
INNER JOIN Proposal_Applicant pa
        ON a.applicant_id = pa.applicant_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Proposal_Applicant pa2
    INNER JOIN Proposal p
            ON pa2.proposal_id  = p.proposal_id
    WHERE pa2.applicant_id = a.applicant_id
      AND p.status IN ('accepted', 'scheduled', 'published')
)
GROUP BY a.applicant_id, applicant_name, a.email, a.organization
ORDER BY total_proposals_submitted DESC;


-- ----------------------------------------------------------
-- Q06: CTE — Phân loại reviewer theo khối lượng công việc
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Giám đốc hội đồng cần báo cáo phân loại reviewer:
--   'Heavy' (≥5 assignment), 'Moderate' (2–4), 'Light' (0–1)
--   để đánh giá sự công bằng trong phân công.
-- Input: Không
-- Kỹ thuật: CTE tính workload → SELECT ngoài phân loại CASE
-- Ý nghĩa kết quả: Báo cáo cân bằng tải cho hội đồng

WITH ReviewerWorkload AS (
    SELECT
        rv.reviewer_id,
        CONCAT(rv.first_name, ' ', rv.last_name) AS reviewer_name,
        rv.organization,
        COUNT(asgn.proposal_id) AS assignment_count,
        COUNT(r.review_id)      AS completed_reviews
    FROM Reviewer rv
    LEFT JOIN Assignment asgn
           ON rv.reviewer_id = asgn.reviewer_id
    LEFT JOIN Review r
           ON asgn.proposal_id = r.assignment_proposal_id
          AND asgn.reviewer_id = r.assignment_reviewer_id
    GROUP BY rv.reviewer_id, reviewer_name, rv.organization
),
WorkloadCategory AS (
    SELECT
        *,
        CASE
            WHEN assignment_count >= 5 THEN 'Heavy'
            WHEN assignment_count BETWEEN 2 AND 4 THEN 'Moderate'
            ELSE 'Light'
        END AS workload_category,
        ROUND(
            completed_reviews * 100.0 /
            NULLIF(assignment_count, 0)
        , 1) AS completion_rate_pct
    FROM ReviewerWorkload
)
SELECT
    reviewer_id,
    reviewer_name,
    organization,
    assignment_count,
    completed_reviews,
    completion_rate_pct,
    workload_category
FROM WorkloadCategory
ORDER BY
    FIELD(workload_category, 'Heavy', 'Moderate', 'Light'),
    assignment_count DESC;


-- ----------------------------------------------------------
-- Q07: Date Functions — Thống kê số đề xuất nhận theo tháng/năm
-- ----------------------------------------------------------
-- Câu hỏi nghiệp vụ:
--   Hội đồng cần phân tích xu hướng nộp đề xuất theo thời
--   gian (tháng, năm) để lập kế hoạch nguồn lực reviewer
--   cho các kỳ tiếp theo.
-- Input: Không (toàn bộ lịch sử)
-- Kỹ thuật: YEAR(), MONTH(), MONTHNAME(), GROUP BY + rollup
-- Ý nghĩa kết quả: Biểu đồ xu hướng nộp hồ sơ theo thời gian

SELECT
    YEAR(date_received)                     AS submission_year,
    MONTH(date_received)                    AS submission_month,
    MONTHNAME(date_received)                AS month_name,
    COUNT(*)                                AS total_received,
    SUM(status = 'accepted'
     OR status = 'scheduled'
     OR status = 'published')               AS total_accepted,
    SUM(status = 'rejected')                AS total_rejected,
    SUM(status = 'under review')            AS total_under_review,
    ROUND(
        SUM(status IN ('accepted','scheduled','published'))
        * 100.0 / COUNT(*),
    1)                                      AS acceptance_rate_pct
FROM Proposal
GROUP BY submission_year, submission_month, month_name
ORDER BY submission_year ASC, submission_month ASC;


-- ----------------------------------------------------------
-- Q08: Truy vấn từ View — Gọi View v_proposal_score_summary
SELECT *
FROM (
    SELECT
        v.`Mã đề xuất`                    AS proposal_id,
        v.`Tiêu đề`                        AS title,
        v.`Trạng thái`                     AS status,
        v.`Số phiếu phản biện đã nộp`      AS total_reviewers,
        v.`Số phiếu đồng ý`                AS votes_accept,
        v.`Số phiếu từ chối`               AS votes_reject,
        ROUND((COALESCE(v.`Điểm trung bình cấp thiết`,  0)
             + COALESCE(v.`Điểm trung bình mạch lạc`,   0)
             + COALESCE(v.`Điểm trung bình phương pháp`,0)
             + COALESCE(v.`Điểm trung bình tác động`,   0)
              ) / 4.0, 2)                  AS avg_overall_score,
        i.season,
        i.year                             AS issue_year,
        i.volume,
        i.issue_number,
        ip.appearance_order,
        ip.start_page
    FROM vw_proposal_review_summary v
    LEFT JOIN Issue_Proposal ip ON v.`Mã đề xuất` = ip.proposal_id
    LEFT JOIN Issue i           ON ip.issue_id     = i.issue_id
) AS ranked
WHERE avg_overall_score >= 8.0
ORDER BY avg_overall_score DESC;