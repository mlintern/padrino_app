# Create User in MYSQL
CREATE USER 'webuser'@'localhost' IDENTIFIED BY 'webuser';

# Grant Permissions to Database in MYSQL
GRANT SELECT ON * . * TO 'webuser'@'localhost';

FLUSH PRIVILEGES;

# Create Database
CREATE DATABASE nretnil_dev;

GRANT ALL PRIVILEGES ON nretnil_dev.* TO 'webuser'@'localhost';

FLUSH PRIVILEGES;