#Clear Data
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS account_properties;
DROP TABLE IF EXISTS todos;

#Clear Migration Info
TRUNCATE TABLE migration_info;