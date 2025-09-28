-- init.sql (updated)
-- Create replication user with native password authentication
-- CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replica_pass';
-- GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
-- GRANT SELECT ON performance_schema.* TO 'replicator'@'%';
-- FLUSH PRIVILEGES;

-- CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED WITH mysql_native_password BY 'replica_pass';
-- GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
-- FLUSH PRIVILEGES;
-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 14, 2025 at 01:38 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12
-- Create replication user on primary
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hoteldb`
--
CREATE DATABASE IF NOT EXISTS `hoteldb`;
USE `hoteldb`;

-- Create application user
CREATE USER IF NOT EXISTS 'myuser'@'%' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON . TO 'myuser'@'%';
-- --------------------------------------------------------

--
-- Table structure for table `activity_log`
--

CREATE TABLE `activity_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `log_name` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `causer_type` varchar(255) DEFAULT NULL,
  `causer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`properties`)),
  `batch_uuid` char(36) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_log`
--

INSERT INTO `activity_log` (`id`, `log_name`, `description`, `subject_type`, `event`, `subject_id`, `causer_type`, `causer_id`, `properties`, `batch_uuid`, `created_at`, `updated_at`) VALUES
(1, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 1, NULL, NULL, '{\"attributes\":{\"name\":\"Yildiz Hotel\",\"location\":\"Beit Wazan, Nablus\",\"description\":\"Yildiz Palace Hotel is one of the most luxurious and famous hotels in Nablus. \\n                                It boasts a prime and strategic location. The hotel features elegant rooms\\n                                 with stunning views, as well as the renowned Babylon Restaurant, the premier\\n                                  choice for delicious oriental and exotic cuisine.\",\"rating\":5,\"image\":\"uploads\\/hotels\\/YildizHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(2, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 2, NULL, NULL, '{\"attributes\":{\"name\":\"Royal Suites Hotel\",\"location\":\"Rafidia, Nablus\",\"description\":\"The Royal Suites Hotel is located in Nablus, in the Rafidia area, \\n                                next to Al-Rawda Mosque. One of the most important features of \\n                                this area is its lively atmosphere, its proximity to shops, \\n                                restaurants, and public parks, and its proximity to the city \\n                                center and the historic Old City.\",\"rating\":4,\"image\":\"uploads\\/hotels\\/RoyalSuitesHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(3, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 3, NULL, NULL, '{\"attributes\":{\"name\":\"Royal Court Hotel\",\"location\":\"downtown, Ramallah\",\"description\":\"Royal Court Hotel the home of the popular Vintage\\n                                Cafe & Sushi & work restaurants\",\"rating\":5,\"image\":\"uploads\\/hotels\\/RoyalCourtHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(4, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 4, NULL, NULL, '{\"attributes\":{\"name\":\"Millennium Hotel\",\"location\":\"Almsyoun, Ramallah\",\"description\":\"Millennium Hotel Ramallah is one of the Millennium chain hotels in\\n                                 the world. is ideally located in the business and diplomatic \\n                                 district of Al Masyoun, just minutes away from the city center,\\n                                  and approximately 1.5 km away from the citys shopping and \\n                                  entertainment district. \\n                                  This upscale 5 star hotel is the only 5*International \\n                                  hotel in the Palestine spans a total of 9665sqm.\",\"rating\":5,\"image\":\"uploads\\/hotels\\/MillenniumHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(5, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 5, NULL, NULL, '{\"attributes\":{\"name\":\"Jacir Palace Hotel\",\"location\":\"jerusalem-Hebron road, Bethlehem\",\"description\":\"The Jacir Palace Hotel in Bethlehem is a monumental landmark \\n                                entwining the noble Arab culture with grand architecture.\\n                                 The hotel is walking distance from the Church of Nativity\\n                                  and a short drive to the old city of Jerusalem.\",\"rating\":5,\"image\":\"uploads\\/hotels\\/JacirHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(6, 'hotel', 'created', 'App\\Models\\Hotel', 'created', 6, NULL, NULL, '{\"attributes\":{\"name\":\"Queen Plaza Hotel\",\"location\":\"Hebron\",\"description\":\"The QPH Hotel is located in the heart of Hebron, one of the largest\\n                                and most vibrant cities in the West Bank. Its stunning historical\\n                                and religious sites make it stand out from the crowd. Book with\\n                                us for business and pleasure and enjoy our unparalleled service,\\n                                which is part of the hotels policy.\",\"rating\":4,\"image\":\"uploads\\/hotels\\/QPlazaHotel.jpg\"}}', NULL, '2025-09-14 11:36:52', '2025-09-14 11:36:52');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `status` enum('requested','approved','rejected') NOT NULL DEFAULT 'requested',
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hotels`
--

CREATE TABLE `hotels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `location` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `image` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `hotels`
--

INSERT INTO `hotels` (`id`, `name`, `location`, `description`, `rating`, `image`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'Yildiz Hotel', 'Beit Wazan, Nablus', 'Yildiz Palace Hotel is one of the most luxurious and famous hotels in Nablus. \n                                It boasts a prime and strategic location. The hotel features elegant rooms\n                                 with stunning views, as well as the renowned Babylon Restaurant, the premier\n                                  choice for delicious oriental and exotic cuisine.', 5, 'uploads/hotels/YildizHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL),
(2, 'Royal Suites Hotel', 'Rafidia, Nablus', 'The Royal Suites Hotel is located in Nablus, in the Rafidia area, \n                                next to Al-Rawda Mosque. One of the most important features of \n                                this area is its lively atmosphere, its proximity to shops, \n                                restaurants, and public parks, and its proximity to the city \n                                center and the historic Old City.', 4, 'uploads/hotels/RoyalSuitesHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL),
(3, 'Royal Court Hotel', 'downtown, Ramallah', 'Royal Court Hotel the home of the popular Vintage\n                                Cafe & Sushi & work restaurants', 5, 'uploads/hotels/RoyalCourtHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL),
(4, 'Millennium Hotel', 'Almsyoun, Ramallah', 'Millennium Hotel Ramallah is one of the Millennium chain hotels in\n                                 the world. is ideally located in the business and diplomatic \n                                 district of Al Masyoun, just minutes away from the city center,\n                                  and approximately 1.5 km away from the citys shopping and \n                                  entertainment district. \n                                  This upscale 5 star hotel is the only 5*International \n                                  hotel in the Palestine spans a total of 9665sqm.', 5, 'uploads/hotels/MillenniumHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL),
(5, 'Jacir Palace Hotel', 'jerusalem-Hebron road, Bethlehem', 'The Jacir Palace Hotel in Bethlehem is a monumental landmark \n                                entwining the noble Arab culture with grand architecture.\n                                 The hotel is walking distance from the Church of Nativity\n                                  and a short drive to the old city of Jerusalem.', 5, 'uploads/hotels/JacirHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL),
(6, 'Queen Plaza Hotel', 'Hebron', 'The QPH Hotel is located in the heart of Hebron, one of the largest\n                                and most vibrant cities in the West Bank. Its stunning historical\n                                and religious sites make it stand out from the crowd. Book with\n                                us for business and pleasure and enjoy our unparalleled service,\n                                which is part of the hotels policy.', 4, 'uploads/hotels/QPlazaHotel.jpg', '2025-09-14 11:36:52', '2025-09-14 11:36:52', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) Not NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_08_07_075417_create_hotels_table', 1),
(5, '2025_08_07_075549_create_rooms_table', 1),
(6, '2025_08_07_075728_create_bookings_table', 1),
(7, '2025_08_10_193051_add_image_to_rooms_table', 1),
(8, '2025_08_20_114520_add_soft_delete_to_hotel_table', 1),
(9, '2025_08_21_083242_create_activity_log_table', 1),
(10, '2025_08_21_083243_add_event_column_to_activity_log_table', 1),
(11, '2025_08_21_083244_add_batch_uuid_column_to_activity_log_table', 1),
(12, '2025_08_28_075331_create_personal_access_tokens_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(50) NOT NULL,
  `price` decimal(8,2) NOT NULL,
  `capacity` tinyint(3) UNSIGNED NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `type`, `price`, `capacity`, `image`, `hotel_id`, `created_at`, `updated_at`) VALUES
(1, 'Single Room', 80.00, 1, 'uploads/hotels/YildizRoom2.jpg', 1, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(2, 'Triple Room', 120.00, 3, 'uploads/hotels/YildizRoom1.jpg', 1, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(3, 'Double Room', 200.00, 2, 'uploads/hotels/RoyalSuitesRoom1.jpg', 2, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(4, 'Suite', 140.00, 2, 'uploads/hotels/RoyalCourtRoom1.jpg', 3, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(5, 'Executive Suite', 350.00, 1, 'uploads/hotels/MillenniumRoom1.jpg', 4, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(6, 'Suite', 500.00, 1, 'uploads/hotels/JacirRoom1.jpg', 5, '2025-09-14 11:36:52', '2025-09-14 11:36:52'),
(7, 'Double Room', 100.00, 2, 'uploads/hotels/QPlazaRoom1.jpg', 6, '2025-09-14 11:36:52', '2025-09-14 11:36:52');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Test User', 'test@example.com', NULL, '$2y$12$.BJw1IwRNqJ4mCZ.fe.Fme2Dy7ej7vgqxT21sfnTf3Z5sBky4u1Bm', NULL, '2025-09-14 11:36:51', '2025-09-14 11:36:51');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `subject` (`subject_type`,`subject_id`),
  ADD KEY `causer` (`causer_type`,`causer_id`),
  ADD KEY `activity_log_log_name_index` (`log_name`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bookings_user_id_foreign` (`user_id`),
  ADD KEY `bookings_room_id_foreign` (`room_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `hotels`
--
ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `rooms_hotel_id_foreign` (`hotel_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hotels`
--
ALTER TABLE `hotels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_room_id_foreign` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_hotel_id_foreign` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- -- Set up replication after all tables are created
-- CHANGE MASTER TO 
-- MASTER_HOST='mysql-primary',
-- MASTER_USER='replicator',
-- MASTER_PASSWORD='replica_pass',
-- MASTER_AUTO_POSITION=1;

-- START SLAVE;