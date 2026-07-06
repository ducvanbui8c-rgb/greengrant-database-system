# 08_admin_backup.md - Cấu hình Quản trị viên, Bảo mật và Backup cơ sở dữ liệu
---

## 1. Thiết lập phân quyền bảo mật tối thiểu (Principle of Least Privilege)

USE `greengrant`;

-- Khởi tạo vai trò
CREATE ROLE IF NOT EXISTS 'role_grant_reporter';

-- Cấp quyền tối thiểu trên các Views báo cáo cho Vai trò
GRANT SELECT ON `greengrant`.`vw_proposal_review_summary` TO 'role_grant_reporter';
GRANT SELECT ON `greengrant`.`vw_issue_publication_layout` TO 'role_grant_reporter';

-- Khởi tạo tài khoản người dùng local phục vụ lab thử nghiệm
CREATE USER IF NOT EXISTS 'reporter_user'@'localhost' IDENTIFIED BY 'GreenGrantLocalLabSecurePass123!';

-- Gán vai trò cho tài khoản
GRANT 'role_grant_reporter' TO 'reporter_user'@'localhost';

-- Thiết lập cấu hình vai trò mặc định khi người dùng đăng nhập
SET DEFAULT ROLE 'role_grant_reporter' TO 'reporter_user'@'localhost';

-- Kiểm tra phân quyền thực tế
SHOW GRANTS FOR 'reporter_user'@'localhost';