-- 1. Thêm danh mục lĩnh vực chuyên môn (Fields)
INSERT INTO field (field_id, description) VALUES
('ENR01', 'Renewable Energy'),
('CLM03', 'Climate Risk Modeling'),
('SOC05', 'Community Impact'),
('WAT02', 'Water Resource Management');

-- 2. Thêm các đợt công bố (ban đầu để release_date là NULL để kích hoạt trigger sau)
INSERT INTO issue (season, year, volume, issue_number, release_date) VALUES
('Xuân', 2026, 1, 1, NULL),          -- issue_id 1: Đợt mới chưa phát hành
('Hạ',   2025, 1, 2, NULL);          -- issue_id 2: Sẽ kích hoạt phát hành bằng lệnh UPDATE sau

-- 3. Thêm thông tin tác giả nộp hồ sơ (Applicants)
INSERT INTO applicant (first_name, last_name, address, email, organization) VALUES
('Van An',   'Nguyen', '144 Xuan Thuy, Cau Giay, Ha Noi', 'an.nguyen@vnu.edu.vn', 'Dai hoc Quoc gia Ha Noi'),
('Thi Bich', 'Tran',   '1 Dai Co Viet, Hai Ba Trung, Ha Noi', 'bich.tran@hust.edu.vn', 'Dai hoc Bach Khoa Ha Noi'),
('Minh',     'Le',     '227 Nguyen Van Cu, Long Bien, Ha Noi', 'minh.le@vnu.edu.vn', 'Truong Dai hoc Khoa hoc Tu nhien'),
('Anh Tuan', 'Pham',   'Phố Vọng, Hai Ba Trung, Ha Noi', 'tuan.pham@neu.edu.vn', 'Dai hoc Kinh te Quoc dan');

-- 4. Thêm danh sách chuyên gia phản biện (Reviewers)
INSERT INTO reviewer (first_name, last_name, email, organization) VALUES
('Quoc',  'Tran', 'quoc.tran@academic.vn', 'Vien Khoa hoc Cong nghe'),
('Minh',  'Le',   'minh.le@university.edu', 'Dai hoc Bach Khoa'),
('Huong', 'Pham', 'huong.pham@research.org', 'Trung tam Nghien cuu Toan cau'),
('Hai',   'Vu',   'hai.vu@hust.edu.vn', 'Dai hoc Bach Khoa Ha Noi');

-- 5. Liên kết năng lực chuyên môn của chuyên gia (Reviewer Fields)
INSERT INTO reviewer_field (reviewer_id, field_id) VALUES
(1, 'ENR01'), (1, 'CLM03'),
(2, 'ENR01'),
(3, 'SOC05'), (3, 'WAT02'),
(4, 'WAT02');

-- 6. Khởi tạo danh sách đề xuất khoa học với trạng thái ban đầu hợp lệ
-- (Đề xuất 1 & 2 để trạng thái ban đầu là 'accepted' để vượt qua Trigger kiểm tra đợt công bố)
INSERT INTO proposal (title, date_received, status, date_accepted, page_count) VALUES
('Nghien cuu san xuat xa phong tai che tu dau an thua', '2025-02-15', 'accepted', '2025-05-10', 12), -- proposal_id 1
('Ung dung thiet bi thuy dien nho cho dong bao vung cao', '2025-01-10', 'accepted', '2025-04-20', 15), -- proposal_id 2
('Giai phap nang luong mat troi cho vung sau vung xa', '2026-03-01', 'under review', NULL, 10),        -- proposal_id 3
('Ung dung IoT giam sat chat luong khong khi do thi', '2026-06-01', 'received', NULL, 8);             -- proposal_id 4

-- 7. Thiết lập liên kết tác giả nộp đề xuất (Proposal Applicants)
INSERT INTO proposal_applicant (proposal_id, applicant_id, display_order) VALUES
(1, 1, 1), (1, 2, 2),
(2, 3, 1),
(3, 1, 1),
(4, 4, 1);

-- 8. Phân công phản biện cho đề xuất số 1 (Assignments)
INSERT INTO assignment (proposal_id, reviewer_id, date_sent) VALUES
(1, 1, '2025-05-02'),
(1, 2, '2025-05-02'),
(1, 3, '2025-05-02');

-- 9. Ghi nhận kết quả chấm điểm phản biện (Reviews)
INSERT INTO review (assignment_proposal_id, assignment_reviewer_id, score_relevance, score_clarity, score_methodology, score_impact, recommendation, date_received) VALUES
(1, 1, 9, 8, 9, 9, 'accept', '2025-05-15'),
(1, 2, 8, 7, 8, 8, 'accept', '2025-05-16'),
(1, 3, 8, 8, 7, 9, 'accept', '2025-05-17');

-- 10. Xếp lịch công bố các đề xuất (Vượt qua trigger trg_ip_only_accepted an toàn)
-- Trigger trg_ip_set_scheduled sẽ tự động cập nhật trạng thái đề xuất 1 và 2 sang 'scheduled'
INSERT INTO issue_proposal (issue_id, proposal_id, appearance_order, start_page) VALUES
(1, 1, 1, 1),   -- Xếp đề xuất 1 vào đợt Xuân 2026
(2, 2, 1, 1);   -- Xếp đề xuất 2 vào đợt Hạ 2025

-- 11. Kích hoạt phát hành Đợt công bố số 2 (Đã phát hành trong quá khứ)
-- Trigger trg_issue_publish sẽ tự động chuyển trạng thái của đề xuất số 2 từ 'scheduled' sang 'published'
UPDATE issue SET release_date = '2025-07-15' WHERE issue_id = 2;