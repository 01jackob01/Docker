CREATE DATABASE IF NOT EXISTS dbTools;

USE dbTools;

CREATE TABLE IF NOT EXISTS history (
    id int(10) unsigned NOT NULL AUTO_INCREMENT,
    db_name char(50) DEFAULT NULL,
    windows_time char(50) DEFAULT NULL,
    execution_time char(50) DEFAULT NULL,
    execute_date_server timestamp NULL DEFAULT current_timestamp(),
    execute_info char(50) DEFAULT NULL,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

