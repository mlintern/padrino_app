# Create User in MYSQL
CREATE USER 'webuser'@'localhost' IDENTIFIED BY 'webuser';

# Grant Permissions to Database in MYSQL
GRANT SELECT ON * . * TO 'webuser'@'localhost';

FLUSH PRIVILEGES;

# Create Database
CREATE DATABASE IF NOT EXISTS nretnil_test;

GRANT ALL PRIVILEGES ON nretnil_test.* TO 'webuser'@'localhost';

FLUSH PRIVILEGES;
