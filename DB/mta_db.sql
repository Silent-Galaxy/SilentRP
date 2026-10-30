-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 30, 2026 at 04:54 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.4.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mta_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(64) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `phone_verified` tinyint(1) DEFAULT 0,
  `verify_code` varchar(10) DEFAULT NULL,
  `remember_token` varchar(64) DEFAULT NULL,
  `session_expire_days` int(11) DEFAULT 7,
  `accepted_rules_version` int(11) DEFAULT 0,
  `serial` varchar(32) NOT NULL,
  `last_serial` varchar(32) DEFAULT NULL,
  `referred_by` varchar(50) DEFAULT NULL,
  `registered_date` datetime DEFAULT current_timestamp(),
  `last_login` datetime DEFAULT NULL,
  `money` int(11) DEFAULT 1000,
  `skin` int(11) DEFAULT 0,
  `x` float DEFAULT 1742.8,
  `y` float DEFAULT -1863.8,
  `z` float DEFAULT 13.6,
  `rotation` float DEFAULT 0,
  `admin_level` int(11) DEFAULT -1,
  `is_banned` tinyint(1) DEFAULT 0,
  `ban_reason` varchar(255) DEFAULT NULL,
  `banned_by` varchar(50) DEFAULT NULL,
  `is_muted` tinyint(1) DEFAULT 0,
  `mute_reason` varchar(255) DEFAULT NULL,
  `admin_perms` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`id`, `username`, `password`, `email`, `phone_number`, `email_verified`, `phone_verified`, `verify_code`, `remember_token`, `session_expire_days`, `accepted_rules_version`, `serial`, `last_serial`, `referred_by`, `registered_date`, `last_login`, `money`, `skin`, `x`, `y`, `z`, `rotation`, `admin_level`, `is_banned`, `ban_reason`, `banned_by`, `is_muted`, `mute_reason`, `admin_perms`) VALUES
(3, 'SilentGalaxy', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', 'amiralisalehpoor@gmail.com', '0987654321', 0, 0, NULL, '7E3363CE958EA51D2B1215D1458A67951BB33535C095285C361E9492C58708E7', 1, 5, 'C8779B48243D9EB1BDB4DED901100C43', 'C8779B48243D9EB1BDB4DED901100C43', NULL, '2026-10-04 02:59:38', '2026-10-30 16:39:33', 1000, 274, 1736.63, -1855.18, 13.4141, 269.672, 0, 0, NULL, NULL, 0, NULL, 'kick,ban,unban,mute,unmute,veh,money,rules');

-- --------------------------------------------------------

--
-- Table structure for table `account_login_logs`
--

CREATE TABLE `account_login_logs` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `serial` varchar(32) NOT NULL,
  `login_time` datetime DEFAULT current_timestamp(),
  `status` enum('success','failed') DEFAULT 'success'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `account_login_logs`
--

INSERT INTO `account_login_logs` (`id`, `account_id`, `ip`, `serial`, `login_time`, `status`) VALUES
(1, 3, '127.0.0.1', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:02:31', 'success'),
(2, 3, '127.0.0.1', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:03:38', 'success'),
(3, 3, '127.0.0.1', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:05:55', 'success'),
(4, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:08:37', 'success'),
(5, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:30:47', 'success'),
(6, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:47:05', 'success'),
(7, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 00:58:28', 'success'),
(8, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 01:08:19', 'success'),
(9, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 01:19:03', 'success'),
(10, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 02:08:16', 'success'),
(11, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 02:55:58', 'success'),
(12, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:05:19', 'success'),
(13, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:14:11', 'success'),
(14, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:19:16', 'success'),
(15, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:19:33', 'success'),
(16, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:21:05', 'success'),
(17, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:28:36', 'success'),
(18, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:38:36', 'success'),
(19, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:40:35', 'success'),
(20, 3, '192.168.1.105', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 03:43:38', 'success'),
(21, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:03:54', 'success'),
(22, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:33:57', 'success'),
(23, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:36:20', 'success'),
(24, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:41:39', 'success'),
(25, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:46:48', 'success'),
(26, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:47:25', 'success'),
(27, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:50:41', 'success'),
(28, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 17:52:30', 'success'),
(29, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 18:24:57', 'success'),
(30, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 18:27:44', 'success'),
(31, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 18:33:34', 'success'),
(32, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 19:05:09', 'success'),
(33, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 19:09:33', 'success'),
(34, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 19:14:13', 'success'),
(35, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 20:21:25', 'success'),
(36, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 20:30:11', 'success'),
(37, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 20:33:04', 'success'),
(38, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 20:41:41', 'success'),
(39, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 21:08:21', 'success'),
(40, 3, '192.168.1.106', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-13 21:17:30', 'success'),
(41, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 17:59:32', 'success'),
(42, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 18:16:51', 'success'),
(43, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 20:53:20', 'success'),
(44, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:25:04', 'success'),
(45, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:31:41', 'success'),
(46, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:36:30', 'success'),
(47, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:41:36', 'success'),
(48, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:42:34', 'success'),
(49, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 21:48:29', 'success'),
(50, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:02:23', 'success'),
(51, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:10:01', 'success'),
(52, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:12:39', 'success'),
(53, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:24:46', 'success'),
(54, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:36:23', 'success'),
(55, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:45:43', 'success'),
(56, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:48:07', 'success'),
(57, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 22:56:43', 'success'),
(58, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 23:21:20', 'success'),
(59, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 23:21:44', 'success'),
(60, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-20 23:28:54', 'success'),
(61, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 13:55:13', 'success'),
(62, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 14:17:18', 'success'),
(63, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 14:37:38', 'success'),
(64, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 14:53:19', 'success'),
(65, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:08:06', 'success'),
(66, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:11:35', 'success'),
(67, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:16:58', 'success'),
(68, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:23:08', 'success'),
(69, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:23:28', 'success'),
(70, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 15:30:31', 'success'),
(71, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 23:21:04', 'success'),
(72, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-25 23:59:17', 'success'),
(73, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 06:28:51', 'success'),
(74, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 07:32:59', 'success'),
(75, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 07:42:25', 'success'),
(76, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 07:52:36', 'success'),
(77, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 07:58:37', 'success'),
(78, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 08:10:24', 'success'),
(79, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 08:26:42', 'success'),
(80, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 08:44:13', 'success'),
(81, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 08:44:28', 'success'),
(82, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 09:10:05', 'success'),
(83, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 09:16:13', 'success'),
(84, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 09:17:11', 'success'),
(85, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 09:33:32', 'success'),
(86, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 09:52:24', 'success'),
(87, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 10:00:25', 'success'),
(88, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 10:12:31', 'success'),
(89, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 10:18:17', 'success'),
(90, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 10:54:32', 'success'),
(91, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 11:03:44', 'success'),
(92, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 11:14:07', 'success'),
(93, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 11:27:11', 'success'),
(94, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 11:43:41', 'success'),
(95, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 11:54:47', 'success'),
(96, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:04:20', 'success'),
(97, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:14:41', 'success'),
(98, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:41:46', 'success'),
(99, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:43:16', 'success'),
(100, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:50:42', 'success'),
(101, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 12:56:15', 'success'),
(102, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 13:00:49', 'success'),
(103, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 13:06:02', 'success'),
(104, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 13:14:35', 'success'),
(105, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 14:40:38', 'success'),
(106, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 15:04:27', 'success'),
(107, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 15:11:47', 'success'),
(108, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 15:59:52', 'success'),
(109, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 16:03:07', 'success'),
(110, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 16:53:26', 'success'),
(111, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 16:53:52', 'success'),
(112, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 16:55:48', 'success'),
(113, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 17:42:41', 'success'),
(114, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 17:44:10', 'success'),
(115, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:00:08', 'success'),
(116, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:01:29', 'success'),
(117, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:02:04', 'success'),
(118, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:12:19', 'success'),
(119, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:24:22', 'success'),
(120, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:30:22', 'success'),
(121, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:36:34', 'success'),
(122, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:48:32', 'success'),
(123, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 18:55:39', 'success'),
(124, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 19:07:05', 'success'),
(125, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 19:09:21', 'success'),
(126, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 20:08:13', 'success'),
(127, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-29 20:08:38', 'success'),
(128, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 13:41:12', 'success'),
(129, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 14:10:37', 'success'),
(130, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 14:18:37', 'success'),
(131, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 16:23:02', 'success'),
(132, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 16:24:18', 'success'),
(133, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 16:31:01', 'success'),
(134, 3, '192.168.1.3', 'C8779B48243D9EB1BDB4DED901100C43', '2026-10-30 16:39:33', 'success');

-- --------------------------------------------------------

--
-- Table structure for table `medical_records`
--

CREATE TABLE `medical_records` (
  `id` int(11) NOT NULL,
  `player_name` varchar(50) NOT NULL,
  `player_serial` varchar(64) NOT NULL,
  `pulse` int(11) DEFAULT 70,
  `blood_pressure` varchar(10) DEFAULT '12/8',
  `status` enum('knocked','transporting','treated','auto_revived') DEFAULT 'knocked',
  `medic_name` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `medical_records`
--

INSERT INTO `medical_records` (`id`, `player_name`, `player_serial`, `pulse`, `blood_pressure`, `status`, `medic_name`, `timestamp`) VALUES
(1, 'SilentGalaxy', 'C8779B48243D9EB1BDB4DED901100C43', 52, '8/5', 'auto_revived', NULL, '2026-10-25 10:51:25'),
(2, 'مصدوم تستی', '', 70, '12/8', 'treated', 'SilentGalaxy', '2026-10-25 12:01:39'),
(3, 'SilentGalaxy', '', 70, '12/8', 'treated', 'پرسنل شیفت', '2026-10-29 11:24:15'),
(4, 'SilentGalaxy', '', 70, '12/8', 'treated', 'پرسنل شیفت', '2026-10-30 11:48:06'),
(5, 'SilentGalaxy', '', 70, '12/8', 'treated', 'پرسنل شیفت', '2026-10-30 15:47:13'),
(6, 'مصدوم تستی', '', 70, '12/8', 'treated', 'SilentGalaxy', '2026-10-30 15:56:37'),
(7, 'مصدوم تستی', '', 70, '12/8', 'treated', 'SilentGalaxy', '2026-10-30 15:57:20'),
(8, 'مصدوم تستی', '', 70, '12/8', 'treated', 'SilentGalaxy', '2026-10-30 16:02:13');

-- --------------------------------------------------------

--
-- Table structure for table `medic_stats`
--

CREATE TABLE `medic_stats` (
  `medic_name` varchar(50) NOT NULL,
  `rescues_count` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `medic_stats`
--

INSERT INTO `medic_stats` (`medic_name`, `rescues_count`) VALUES
('SilentGalaxy', 4);

-- --------------------------------------------------------

--
-- Table structure for table `patient_stats`
--

CREATE TABLE `patient_stats` (
  `patient_name` varchar(50) NOT NULL,
  `visits_count` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_stats`
--

INSERT INTO `patient_stats` (`patient_name`, `visits_count`) VALUES
('SilentGalaxy', 3),
('مصدوم تستی', 4),
('مصدوم خیابانی (82)', 2);

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `serial` varchar(64) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `money` int(11) DEFAULT 2500,
  `bank` int(11) DEFAULT 10000,
  `health` float DEFAULT 100,
  `armor` float DEFAULT 0,
  `last_login` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `server_control_logs`
--

CREATE TABLE `server_control_logs` (
  `id` int(11) NOT NULL,
  `admin_name` varchar(50) NOT NULL,
  `admin_ip` varchar(45) DEFAULT '',
  `action` varchar(50) NOT NULL,
  `target` varchar(100) DEFAULT '',
  `details` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `server_managed_resources`
--

CREATE TABLE `server_managed_resources` (
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT 'manual',
  `enabled` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `server_managed_resources`
--

INSERT INTO `server_managed_resources` (`name`, `category`, `enabled`, `updated_at`) VALUES
('admin', 'auto', 1, '2026-10-20 14:29:01'),
('admin_vehicles', 'auto', 1, '2026-10-20 14:29:01'),
('ajax', 'auto', 1, '2026-10-20 14:29:01'),
('auth', 'auto', 1, '2026-10-20 14:29:01'),
('db', 'auto', 1, '2026-10-20 14:46:45'),
('death_system', 'auto', 1, '2026-10-30 12:52:45'),
('defaultstats', 'auto', 1, '2026-10-20 14:29:01'),
('helpmanager', 'auto', 1, '2026-10-20 14:29:01'),
('hud', 'auto', 1, '2026-10-20 14:29:01'),
('ipb', 'auto', 1, '2026-10-20 14:29:01'),
('iran_cars', 'auto', 1, '2026-10-20 14:29:01'),
('joinquit', 'auto', 1, '2026-10-20 14:29:01'),
('mapcycler', 'auto', 1, '2026-10-20 14:29:01'),
('mapmanager', 'auto', 1, '2026-10-20 14:29:01'),
('parachute', 'auto', 1, '2026-10-20 14:29:01'),
('performancebrowser', 'auto', 1, '2026-10-20 14:29:01'),
('playercolors', 'auto', 1, '2026-10-20 14:29:01'),
('reload', 'auto', 1, '2026-10-20 14:29:01'),
('resourcebrowser', 'auto', 1, '2026-10-20 14:29:01'),
('resourcemanager', 'auto', 1, '2026-10-20 14:29:01'),
('scoreboard', 'auto', 1, '2026-10-20 14:29:01'),
('server_control_panel', 'auto', 1, '2026-10-20 14:29:01'),
('server_rules', 'auto', 1, '2026-10-30 12:52:45'),
('spawnmanager', 'auto', 1, '2026-10-20 14:29:01'),
('speedometer', 'auto', 1, '2026-10-20 14:29:01'),
('v_adminfly', 'auto', 1, '2026-10-30 12:52:45'),
('v_mechanic', 'auto', 1, '2026-10-30 12:52:45'),
('veh_core', 'auto', 1, '2026-10-30 12:52:45'),
('voice', 'auto', 1, '2026-10-20 14:29:01'),
('votemanager', 'auto', 1, '2026-10-20 14:29:01'),
('web_scoreboard', 'auto', 1, '2026-10-30 12:52:45'),
('webadmin', 'auto', 1, '2026-10-20 14:29:01');

-- --------------------------------------------------------

--
-- Table structure for table `server_rules`
--

CREATE TABLE `server_rules` (
  `id` int(11) NOT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `title` varchar(150) NOT NULL DEFAULT 'قوانین و مقررات رسمی سرور',
  `content` text NOT NULL,
  `created_by` varchar(50) NOT NULL DEFAULT 'SilentGalaxy',
  `created_at` datetime DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `server_rules`
--

INSERT INTO `server_rules` (`id`, `version`, `title`, `content`, `created_by`, `created_at`, `is_active`) VALUES
(1, 1, 'قوانین عمومی سرور شبیه‌سازی زندگی واقعی (Roleplay)', '۱. احترام به کلیه بازیکنان و پرسنل سرور الزامی است.\n۲. هرگونه استفاده از چیت، باگ و ابزارهای تقلب موجب مسدودیت دائم خواهد شد.\n۳. رعایت اصول رول‌پلی (Non-RP, DM, VDM) در تمام مناطق شهر اجباری است.\n۴. تبلیغ سرورها یا شبکه‌های اجتماعی متفرقه اکیداً ممنوع می‌باشد.\n۵. مسئولیت حفظ امنیت نام کاربری و رمز عبور بر عهده شخص بازیکن است.', 'SilentGalaxy', '2026-10-13 01:07:42', 0),
(2, 2, 'قوانين جديد.0000005655', 'احترام به قوانين واجب است.', 'SilentGalaxy', '2026-10-29 16:58:21', 1),
(3, 3, 'احترام به همه قوانين احترام به خود است', 'احترام احترام مياره...', 'SilentGalaxy', '2026-10-29 17:43:54', 0),
(4, 4, 'احترام به همه قوانين احترام به خود است پس باهم احترام بگذاريم', 'احترام احترام مياره... قوانين رو رعايت کنيم باهم...', 'SilentGalaxy', '2026-10-29 18:01:02', 0),
(5, 5, 'بروزرساني قوانين شهروندي---', 'براي پليس احترام بيشتري به خرج بديم.000', 'SilentGalaxy', '2026-10-29 18:13:48', 0);

-- --------------------------------------------------------

--
-- Table structure for table `server_settings`
--

CREATE TABLE `server_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_val` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `server_settings`
--

INSERT INTO `server_settings` (`setting_key`, `setting_val`) VALUES
('max_session_days', '30'),
('min_session_days', '1'),
('sc_temp', '29'),
('sc_weather', '1');

-- --------------------------------------------------------

--
-- Table structure for table `server_vehicles`
--

CREATE TABLE `server_vehicles` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rx` float NOT NULL,
  `ry` float NOT NULL,
  `rz` float NOT NULL,
  `plate` varchar(32) DEFAULT 'IRAN',
  `veh_color1` varchar(32) NOT NULL DEFAULT '255,255,255,255',
  `veh_color2` varchar(32) NOT NULL DEFAULT '0,0,0,255',
  `first_owner_type` enum('player','faction','none') NOT NULL DEFAULT 'none',
  `first_owner_id` int(11) DEFAULT NULL,
  `first_owner_name` varchar(100) DEFAULT NULL,
  `first_faction_tag` varchar(50) DEFAULT NULL,
  `first_assigned_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `veh_name` varchar(100) DEFAULT 'خودرو',
  `veh_type` enum('personal','faction','public') DEFAULT 'public',
  `faction_tag` varchar(50) DEFAULT NULL,
  `key_code` varchar(100) DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `trunk_max_weight` float DEFAULT 60,
  `fuel` float DEFAULT 100,
  `locked` tinyint(4) DEFAULT 0,
  `mileage` float DEFAULT 0 COMMENT 'کارکرد خودرو به کیلومتر',
  `engine_condition` float DEFAULT 100 COMMENT 'سلامت موتور ۰ تا ۱۰۰',
  `battery_charge` float DEFAULT 100 COMMENT 'شارژ باتری ۰ تا ۱۰۰',
  `spark_plug_health` float DEFAULT 100 COMMENT 'سلامت شمع و استارت',
  `oil_health` float DEFAULT 100 COMMENT 'درصد تمیزی روغن',
  `oil_type` varchar(20) DEFAULT '10W-40' COMMENT 'نوع روغن داخل موتور',
  `radiator_health` float DEFAULT 100 COMMENT 'سلامت رادیاتور',
  `alarm_system` tinyint(1) DEFAULT 0 COMMENT 'آیا دزدگیر نصب است؟',
  `glovebox_max_weight` float DEFAULT 5 COMMENT 'ظرفیت داشبورد',
  `max_total_weight` float NOT NULL DEFAULT 1000,
  `last_mechanic_check` varchar(100) DEFAULT 'تاکنون سرویس نشده' COMMENT 'تاریخچه آخرین بازدید',
  `custom_handling` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `server_vehicles`
--

INSERT INTO `server_vehicles` (`id`, `model`, `x`, `y`, `z`, `rx`, `ry`, `rz`, `plate`, `veh_color1`, `veh_color2`, `first_owner_type`, `first_owner_id`, `first_owner_name`, `first_faction_tag`, `first_assigned_at`, `created_at`, `updated_at`, `veh_name`, `veh_type`, `faction_tag`, `key_code`, `owner_id`, `trunk_max_weight`, `fuel`, `locked`, `mileage`, `engine_condition`, `battery_charge`, `spark_plug_health`, `oil_health`, `oil_type`, `radiator_health`, `alarm_system`, `glovebox_max_weight`, `max_total_weight`, `last_mechanic_check`, `custom_handling`) VALUES
(1, 445, 1732.52, -1847.38, 13.3266, 0.549316, 359.89, 155.764, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:01:09', '2026-10-06 14:24:02', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(2, 445, 1736.23, -1847.91, 13.3277, 0.543823, 359.896, 155.391, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:01:09', '2026-10-29 06:42:42', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(3, 405, 1749.89, -1847.68, 13.3672, 0.829468, 359.868, 177.693, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:04:52', '2026-10-06 14:23:12', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(4, 422, 1733.71, -1863.4, 13.5834, 358.967, 0.093384, 325.289, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:05:36', '2026-10-06 14:24:43', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(5, 578, 1791.11, -1932.86, 13.6435, 359.962, 359.962, 353.276, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:26:21', '2026-10-06 14:26:21', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(6, 531, 1795.75, -1933.49, 13.334, 359.231, 0.016479, 2.51038, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:26:53', '2026-10-06 14:26:53', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(7, 438, 1776.78, -1910.54, 13.8374, 359.132, 0.071411, 291.138, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:28:15', '2026-10-06 14:28:15', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(8, 496, 1793.18, -1868.26, 13.0107, 0.571289, 359.907, 1.09863, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:28:43', '2026-10-06 14:29:37', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(9, 492, 1797.95, -1865.08, 13.5453, 359.731, 0.065918, 359.78, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:28:59', '2026-10-06 16:13:56', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(10, 496, 1803.13, -1866.92, 13.0179, 0.450439, 359.857, 0.379028, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:29:19', '2026-10-06 14:29:19', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(11, 517, 1763.64, -1863.95, 13.4674, 359.401, 0.12085, 358.819, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:30:02', '2026-10-06 14:30:02', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(12, 561, 1728.5, -1846.91, 13.3315, 359.868, 359.995, 160.054, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:30:22', '2026-10-06 14:30:22', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(13, 467, 1724.01, -1846.98, 13.2109, 359.813, 0.016479, 187.443, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:30:38', '2026-10-06 14:30:38', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(14, 461, 1730.49, -1855.01, 13.0151, 2.12036, 359.995, 271.236, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:31:14', '2026-10-29 12:08:03', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(15, 522, 1727.56, -1855.02, 12.9446, 359.017, 359.995, 267.88, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:31:43', '2026-10-29 12:08:11', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(16, 589, 1728.21, -1852.59, 13.3206, 359.863, 0.027466, 270.884, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:32:13', '2026-10-30 15:33:23', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"police\", \"speed\": 1 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(17, 547, 1755.64, -1847.39, 13.4899, 358.879, 359.951, 167.234, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:32:43', '2026-10-06 14:32:43', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(18, 599, 1704.81, -1856.18, 13.379, 358.462, 0.20874, 269.072, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:33:20', '2026-10-06 14:33:20', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(19, 599, 1704.75, -1852.11, 13.3747, 358.495, 0.197754, 270.247, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:33:56', '2026-10-06 14:33:56', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(20, 596, 1713.55, -1847.43, 13.2861, 359.78, 0.060425, 199.633, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:34:19', '2026-10-06 14:34:19', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(22, 600, 1752.7, -1862.83, 13.5232, 358.434, 0.175781, 2.2522, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:35:34', '2026-10-20 19:38:11', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"none\", \"speed\": 3.5 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(23, 467, 1760.46, -1863.69, 13.2121, 359.753, 359.978, 9.53064, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:36:04', '2026-10-06 14:36:04', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(24, 437, 1776.71, -1915.32, 13.6607, 0.428467, 0.021973, 277.614, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:42:40', '2026-10-06 14:43:25', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(25, 436, 1776.74, -1863.89, 13.4346, 0.55481, 359.357, 0.966797, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:44:24', '2026-10-06 14:44:24', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(26, 400, 1759.12, -1847.17, 13.7669, 0.060425, 359.989, 165.718, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:47:46', '2026-10-06 14:47:46', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(27, 575, 1808.1, -1867.27, 13.5513, 0.087891, 359.989, 357.896, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:48:28', '2026-10-06 14:48:28', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(28, 419, 1773.45, -1863.81, 13.0437, 358.44, 359.995, 11.0083, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:49:41', '2026-10-20 19:26:18', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"none\", \"speed\": 1 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(29, 416, 1706.69, -1848.04, 13.6621, 358.583, 359.94, 223.929, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:50:09', '2026-10-06 14:50:09', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(30, 431, 1778.83, -1918.94, 14.0049, 0.186768, 359.973, 279.399, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:51:58', '2026-10-06 14:51:58', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(31, 437, 1776.95, -1923.47, 13.6365, 0.609741, 0.021973, 276.454, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:52:34', '2026-10-06 14:52:34', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(32, 420, 1776.57, -1906.25, 13.3265, 359.033, 0.043945, 289.715, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:53:05', '2026-10-06 14:53:05', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(33, 445, 1787.27, -1865.1, 13.3199, 0.571289, 359.868, 0.65918, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:54:19', '2026-10-06 14:54:19', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(34, 438, 1696.66, -1919.86, 14.0056, 359.055, 0.164795, 32.9535, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:56:38', '2026-10-06 14:56:57', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(35, 438, 1696.58, -1914.34, 13.9991, 359.044, 0.219727, 33.3655, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:57:21', '2026-10-06 14:57:21', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(36, 438, 1696.87, -1909.78, 14.0027, 358.934, 358.006, 34.3817, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:57:47', '2026-10-06 14:57:47', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(37, 420, 1697.58, -1904.73, 13.4987, 358.885, 359.874, 34.2224, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:58:21', '2026-10-06 14:58:21', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(38, 420, 1697.67, -1900.14, 13.4948, 358.857, 359.879, 35.8319, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:58:38', '2026-10-06 14:58:38', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(39, 420, 1697.69, -1896.28, 13.496, 358.857, 359.885, 36.6284, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:58:53', '2026-10-06 14:58:53', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(40, 422, 1765.29, -1846.13, 13.586, 358.94, 0.043945, 194.936, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 14:59:36', '2026-10-06 14:59:36', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(41, 422, 1769.22, -1846.16, 13.5864, 358.94, 0.060425, 165.289, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 15:00:07', '2026-10-06 15:00:07', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(42, 575, 1782.84, -1846.86, 13.5477, 0.082397, 0.038452, 149.985, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 15:01:00', '2026-10-06 15:01:00', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(43, 599, 1844.83, -1871.8, 13.2003, 358.423, 0.483398, 359.863, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 15:03:01', '2026-10-06 15:03:01', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(44, 405, 1779.88, -1863.99, 13.3687, 0.840454, 359.94, 347.195, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-06 17:46:18', '2026-10-06 17:46:18', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(45, 561, 1727.64, -1857.98, 13.1683, 359.769, 359.923, 269.67, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-11 21:13:52', '2026-10-29 07:47:41', 'خودرو', 'personal', NULL, NULL, 3, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"none\", \"speed\": 1 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(46, 438, 1191.32, -1355.88, 13.9052, 358.742, 349.926, 180.379, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 19:59:46', '2026-10-25 20:04:44', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"none\", \"speed\": 1 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": { \"suspensionLowerLimit\": -0.34999999 }, \"damageProof\": false } ]'),
(47, 420, 1219.83, -1337.28, 13.4267, 358.995, 0.153809, 46.8951, 'IRAN', '206,64,64,255', '236,9,9,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:14:04', '2026-10-25 20:26:13', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(48, 420, 1219.44, -1342.01, 13.4303, 359.017, 0.137329, 46.9666, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:14:34', '2026-10-25 20:14:34', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(49, 420, 1219.09, -1346.77, 13.4337, 358.978, 0.065918, 44.9341, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:14:53', '2026-10-25 20:14:53', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(50, 416, 1181.96, -1339.31, 13.7975, 354.814, 357.951, 269.489, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:15:30', '2026-10-25 20:15:30', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(51, 416, 1177.75, -1310.44, 13.9266, 353.99, 0.060425, 269.885, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:16:18', '2026-10-25 20:28:31', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(52, 416, 1184.16, -1331.77, 13.6753, 358.281, 0.049438, 286.084, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:16:50', '2026-10-30 15:53:57', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"police\", \"speed\": 1 }, \"colors\": { \"c1\": \"#ffffff\", \"c2\": \"#000000\", \"light\": \"#ffffff\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(53, 416, 1222.17, -1325.79, 13.577, 358.27, 359.984, 93.5815, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:17:23', '2026-10-25 20:28:12', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(54, 416, 1184.43, -1334.97, 13.6772, 358.358, 0.291138, 288.018, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:18:23', '2026-10-25 20:23:39', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(55, 416, 1177.61, -1306.81, 14.0002, 355.611, 1.25244, 269.945, 'IRAN', '255,255,255,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:18:53', '2026-10-25 20:27:16', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', NULL),
(56, 599, 1221.43, -1329.65, 13.2943, 358.478, 0.346069, 51.1029, 'IRAN', '255,163,163,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:20:55', '2026-10-29 02:59:17', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"police\", \"speed\": 0.2 }, \"colors\": { \"c1\": \"#ffa3a3\", \"c2\": \"#000000\", \"light\": \"#000000\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]'),
(57, 599, 1221.01, -1322.06, 13.2976, 358.358, 0.340576, 136.461, 'IRAN', '255,163,163,255', '0,0,0,255', 'none', NULL, NULL, NULL, NULL, '2026-10-25 20:21:44', '2026-10-29 02:59:35', 'خودرو', 'public', NULL, NULL, NULL, 60, 100, 0, 0, 100, 100, 100, 100, '10W-40', 100, 0, 5, 1000, 'تاکنون سرویس نشده', '[ { \"dynamicLighting\": { \"target\": \"lights\", \"pattern\": \"police\", \"speed\": 0.2 }, \"colors\": { \"c1\": \"#ffa3a3\", \"c2\": \"#000000\", \"light\": \"#000000\" }, \"transmissionMode\": \"auto\", \"handling\": [ ], \"damageProof\": false } ]');

-- --------------------------------------------------------

--
-- Table structure for table `user_rule_acceptances`
--

CREATE TABLE `user_rule_acceptances` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `rule_version` int(11) NOT NULL,
  `accepted_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_rule_acceptances`
--

INSERT INTO `user_rule_acceptances` (`id`, `account_id`, `rule_version`, `accepted_at`) VALUES
(1, 3, 1, '2026-10-13 01:19:03'),
(2, 3, 2, '2026-10-29 17:42:41'),
(3, 3, 3, '2026-10-29 17:43:54'),
(4, 3, 4, '2026-10-29 18:01:02'),
(5, 3, 5, '2026-10-29 18:13:48');

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_handling_profiles`
--

CREATE TABLE `vehicle_handling_profiles` (
  `id` int(11) NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `profile_name` varchar(50) NOT NULL,
  `handling_data` longtext NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `vehicle_handling_profiles`
--

INSERT INTO `vehicle_handling_profiles` (`id`, `account_id`, `profile_name`, `handling_data`, `created_at`) VALUES
(1, 3, 'SilentGalaxy', '[ { \"brakeBias\": 1, \"numberOfGears\": 5, \"engineAcceleration\": 90, \"steeringLock\": 80, \"driveType\": \"f\", \"mass\": 4500, \"brakeDeceleration\": 35, \"collisionDamageMultiplier\": 0, \"tractionMultiplier\": 2.5999999, \"suspensionDamping\": 0.60000002, \"maxVelocity\": 480 } ]', '2026-10-20 22:05:11'),
(2, 3, 'pd', '[ [ ] ]', '2026-10-25 23:50:37');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_referred_by` (`referred_by`),
  ADD KEY `idx_registered_date` (`registered_date`);

--
-- Indexes for table `account_login_logs`
--
ALTER TABLE `account_login_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account_id` (`account_id`);

--
-- Indexes for table `medical_records`
--
ALTER TABLE `medical_records`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `medic_stats`
--
ALTER TABLE `medic_stats`
  ADD PRIMARY KEY (`medic_name`);

--
-- Indexes for table `patient_stats`
--
ALTER TABLE `patient_stats`
  ADD PRIMARY KEY (`patient_name`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `serial` (`serial`);

--
-- Indexes for table `server_control_logs`
--
ALTER TABLE `server_control_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `server_managed_resources`
--
ALTER TABLE `server_managed_resources`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `server_rules`
--
ALTER TABLE `server_rules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `server_settings`
--
ALTER TABLE `server_settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- Indexes for table `server_vehicles`
--
ALTER TABLE `server_vehicles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_rule_acceptances`
--
ALTER TABLE `user_rule_acceptances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_user_rule` (`account_id`,`rule_version`);

--
-- Indexes for table `vehicle_handling_profiles`
--
ALTER TABLE `vehicle_handling_profiles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `account_login_logs`
--
ALTER TABLE `account_login_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- AUTO_INCREMENT for table `medical_records`
--
ALTER TABLE `medical_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `server_control_logs`
--
ALTER TABLE `server_control_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `server_rules`
--
ALTER TABLE `server_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `server_vehicles`
--
ALTER TABLE `server_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `user_rule_acceptances`
--
ALTER TABLE `user_rule_acceptances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `vehicle_handling_profiles`
--
ALTER TABLE `vehicle_handling_profiles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
