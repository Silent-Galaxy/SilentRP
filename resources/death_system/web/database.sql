CREATE DATABASE IF NOT EXISTS `mta_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mta_db`;

-- سابقه درمان‌ها
CREATE TABLE IF NOT EXISTS `medical_records` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_name` VARCHAR(50) NOT NULL,
    `medic_name` VARCHAR(50) DEFAULT NULL,
    `status` VARCHAR(20) DEFAULT 'treated',
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- آمار مدیک‌ها (تعداد بیماران نجات‌یافته)
CREATE TABLE IF NOT EXISTS `medic_stats` (
    `medic_name` VARCHAR(50) PRIMARY KEY,
    `rescues_count` INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- آمار مراجعین و بیماران (تعداد دفعات بستری)
CREATE TABLE IF NOT EXISTS `patient_stats` (
    `patient_name` VARCHAR(50) PRIMARY KEY,
    `visits_count` INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;