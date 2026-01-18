-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 18, 2026 at 10:31 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pharmacy_db`
--
CREATE DATABASE IF NOT EXISTS `pharmacy_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `pharmacy_db`;

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--
-- Creation: Jan 17, 2026 at 12:56 PM
-- Last update: Jan 17, 2026 at 11:34 PM
--

DROP TABLE IF EXISTS `inventory`;
CREATE TABLE IF NOT EXISTS `inventory` (
  `inventory_id` int(11) NOT NULL AUTO_INCREMENT,
  `med_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`inventory_id`),
  KEY `med_id` (`med_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `inventory`:
--   `med_id`
--       `medications` -> `med_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `medications`
--
-- Creation: Jan 17, 2026 at 12:55 PM
-- Last update: Jan 17, 2026 at 01:25 PM
--

DROP TABLE IF EXISTS `medications`;
CREATE TABLE IF NOT EXISTS `medications` (
  `med_id` int(11) NOT NULL AUTO_INCREMENT,
  `med_name` varchar(100) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`med_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `medications`:
--   `category_id`
--       `medication_categories` -> `category_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `medication_categories`
--
-- Creation: Jan 17, 2026 at 12:55 PM
-- Last update: Jan 17, 2026 at 01:25 PM
--

DROP TABLE IF EXISTS `medication_categories`;
CREATE TABLE IF NOT EXISTS `medication_categories` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `medication_categories`:
--

-- --------------------------------------------------------

--
-- Table structure for table `purchases`
--
-- Creation: Jan 17, 2026 at 12:56 PM
-- Last update: Jan 17, 2026 at 01:25 PM
--

DROP TABLE IF EXISTS `purchases`;
CREATE TABLE IF NOT EXISTS `purchases` (
  `purchase_id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`purchase_id`),
  KEY `supplier_id` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `purchases`:
--   `supplier_id`
--       `suppliers` -> `supplier_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `purchase_details`
--
-- Creation: Jan 17, 2026 at 12:56 PM
-- Last update: Jan 17, 2026 at 01:25 PM
--

DROP TABLE IF EXISTS `purchase_details`;
CREATE TABLE IF NOT EXISTS `purchase_details` (
  `purchase_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `purchase_id` int(11) DEFAULT NULL,
  `med_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`purchase_detail_id`),
  KEY `purchase_id` (`purchase_id`),
  KEY `med_id` (`med_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `purchase_details`:
--   `purchase_id`
--       `purchases` -> `purchase_id`
--   `med_id`
--       `medications` -> `med_id`
--

--
-- Triggers `purchase_details`
--
DROP TRIGGER IF EXISTS `trg_increase_stock_after_purchase`;
DELIMITER $$
CREATE TRIGGER `trg_increase_stock_after_purchase` AFTER INSERT ON `purchase_details` FOR EACH ROW BEGIN
  UPDATE inventory
  SET quantity = quantity + NEW.quantity
  WHERE med_id = NEW.med_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--
-- Creation: Jan 17, 2026 at 12:56 PM
-- Last update: Jan 17, 2026 at 01:30 PM
--

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `sale_id` int(11) NOT NULL AUTO_INCREMENT,
  `sale_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`sale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `sales`:
--

-- --------------------------------------------------------

--
-- Table structure for table `sale_details`
--
-- Creation: Jan 17, 2026 at 12:57 PM
-- Last update: Jan 17, 2026 at 11:34 PM
--

DROP TABLE IF EXISTS `sale_details`;
CREATE TABLE IF NOT EXISTS `sale_details` (
  `sale_detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `sale_id` int(11) DEFAULT NULL,
  `med_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`sale_detail_id`),
  KEY `sale_id` (`sale_id`),
  KEY `med_id` (`med_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `sale_details`:
--   `sale_id`
--       `sales` -> `sale_id`
--   `med_id`
--       `medications` -> `med_id`
--

--
-- Triggers `sale_details`
--
DROP TRIGGER IF EXISTS `trg_prevent_negative_stock`;
DELIMITER $$
CREATE TRIGGER `trg_prevent_negative_stock` BEFORE INSERT ON `sale_details` FOR EACH ROW BEGIN
  DECLARE current_stock INT;

  SELECT quantity INTO current_stock
  FROM inventory
  WHERE med_id = NEW.med_id;

  IF current_stock < NEW.quantity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient stock for this medication';
  END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_reduce_stock_after_sale`;
DELIMITER $$
CREATE TRIGGER `trg_reduce_stock_after_sale` AFTER INSERT ON `sale_details` FOR EACH ROW BEGIN
  UPDATE inventory
  SET quantity = quantity - NEW.quantity
  WHERE med_id = NEW.med_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--
-- Creation: Jan 17, 2026 at 12:56 PM
-- Last update: Jan 17, 2026 at 01:25 PM
--

DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE IF NOT EXISTS `suppliers` (
  `supplier_id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `suppliers`:
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_low_stock`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `view_low_stock`;
CREATE TABLE IF NOT EXISTS `view_low_stock` (
`med_id` int(11)
,`med_name` varchar(100)
,`quantity` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_medication_inventory`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `view_medication_inventory`;
CREATE TABLE IF NOT EXISTS `view_medication_inventory` (
`med_id` int(11)
,`med_name` varchar(100)
,`category_name` varchar(100)
,`quantity` int(11)
,`price` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_purchase_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `view_purchase_details`;
CREATE TABLE IF NOT EXISTS `view_purchase_details` (
`purchase_id` int(11)
,`purchase_date` date
,`supplier_name` varchar(100)
,`med_name` varchar(100)
,`quantity` int(11)
,`cost` decimal(10,2)
,`line_total` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_sales_details`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `view_sales_details`;
CREATE TABLE IF NOT EXISTS `view_sales_details` (
`sale_id` int(11)
,`sale_date` date
,`med_name` varchar(100)
,`quantity` int(11)
,`price` decimal(10,2)
,`line_total` decimal(20,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_sales_summary`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `view_sales_summary`;
CREATE TABLE IF NOT EXISTS `view_sales_summary` (
`sale_id` int(11)
,`sale_date` date
,`total_amount` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Structure for view `view_low_stock`
--
DROP TABLE IF EXISTS `view_low_stock`;

DROP VIEW IF EXISTS `view_low_stock`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_low_stock`  AS SELECT `m`.`med_id` AS `med_id`, `m`.`med_name` AS `med_name`, `i`.`quantity` AS `quantity` FROM (`medications` `m` join `inventory` `i` on(`m`.`med_id` = `i`.`med_id`)) WHERE `i`.`quantity` < 20 ;

-- --------------------------------------------------------

--
-- Structure for view `view_medication_inventory`
--
DROP TABLE IF EXISTS `view_medication_inventory`;

DROP VIEW IF EXISTS `view_medication_inventory`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_medication_inventory`  AS SELECT `m`.`med_id` AS `med_id`, `m`.`med_name` AS `med_name`, `mc`.`category_name` AS `category_name`, `i`.`quantity` AS `quantity`, `i`.`price` AS `price` FROM ((`medications` `m` join `medication_categories` `mc` on(`m`.`category_id` = `mc`.`category_id`)) join `inventory` `i` on(`m`.`med_id` = `i`.`med_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_purchase_details`
--
DROP TABLE IF EXISTS `view_purchase_details`;

DROP VIEW IF EXISTS `view_purchase_details`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_purchase_details`  AS SELECT `p`.`purchase_id` AS `purchase_id`, `p`.`purchase_date` AS `purchase_date`, `s`.`supplier_name` AS `supplier_name`, `m`.`med_name` AS `med_name`, `pd`.`quantity` AS `quantity`, `pd`.`cost` AS `cost`, `pd`.`quantity`* `pd`.`cost` AS `line_total` FROM (((`purchases` `p` join `suppliers` `s` on(`p`.`supplier_id` = `s`.`supplier_id`)) join `purchase_details` `pd` on(`p`.`purchase_id` = `pd`.`purchase_id`)) join `medications` `m` on(`pd`.`med_id` = `m`.`med_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_sales_details`
--
DROP TABLE IF EXISTS `view_sales_details`;

DROP VIEW IF EXISTS `view_sales_details`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sales_details`  AS SELECT `s`.`sale_id` AS `sale_id`, `s`.`sale_date` AS `sale_date`, `m`.`med_name` AS `med_name`, `sd`.`quantity` AS `quantity`, `sd`.`price` AS `price`, `sd`.`quantity`* `sd`.`price` AS `line_total` FROM ((`sales` `s` join `sale_details` `sd` on(`s`.`sale_id` = `sd`.`sale_id`)) join `medications` `m` on(`sd`.`med_id` = `m`.`med_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_sales_summary`
--
DROP TABLE IF EXISTS `view_sales_summary`;

DROP VIEW IF EXISTS `view_sales_summary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_sales_summary`  AS SELECT `sales`.`sale_id` AS `sale_id`, `sales`.`sale_date` AS `sale_date`, `sales`.`total_amount` AS `total_amount` FROM `sales` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`med_id`) REFERENCES `medications` (`med_id`);

--
-- Constraints for table `medications`
--
ALTER TABLE `medications`
  ADD CONSTRAINT `medications_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `medication_categories` (`category_id`);

--
-- Constraints for table `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `purchases_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`);

--
-- Constraints for table `purchase_details`
--
ALTER TABLE `purchase_details`
  ADD CONSTRAINT `purchase_details_ibfk_1` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`purchase_id`),
  ADD CONSTRAINT `purchase_details_ibfk_2` FOREIGN KEY (`med_id`) REFERENCES `medications` (`med_id`);

--
-- Constraints for table `sale_details`
--
ALTER TABLE `sale_details`
  ADD CONSTRAINT `sale_details_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`sale_id`),
  ADD CONSTRAINT `sale_details_ibfk_2` FOREIGN KEY (`med_id`) REFERENCES `medications` (`med_id`);
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
