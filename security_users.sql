USE pensionsDB
GO
-- Create admin user
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'AdminPass123';

-- Create data entry user
CREATE USER 'data_entry'@'localhost' IDENTIFIED BY 'DataEntryPass123';

-- Create reporting user (read-only)
CREATE USER 'reporting_user'@'localhost' IDENTIFIED BY 'ReportPass123';


GRANT ALL PRIVILEGES ON pensionsDB.* TO 'admin_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON pensionsDB.* TO 'data_entry'@'localhost';
GRANT SELECT ON pensionsDB.* TO 'reporting_user'@'localhost';


FLUSH PRIVILEGES;
