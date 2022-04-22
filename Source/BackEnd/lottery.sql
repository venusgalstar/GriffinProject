/*
 Navicat Premium Data Transfer

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 100411
 Source Host           : 127.0.0.1:3306
 Source Schema         : lottery

 Target Server Type    : MySQL
 Target Server Version : 100411
 File Encoding         : 65001

 Date: 21/04/2022 23:57:20
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for claim_history
-- ----------------------------
DROP TABLE IF EXISTS `claim_history`;
CREATE TABLE `claim_history`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `wallet_index` int NULL DEFAULT NULL COMMENT 'wallet index',
  `address` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'wallet address for claiming nest',
  `claim_time` datetime NULL DEFAULT NULL COMMENT 'last claim time',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 166 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for first_start
-- ----------------------------
DROP TABLE IF EXISTS `first_start`;
CREATE TABLE `first_start`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_start` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nfts
-- ----------------------------
DROP TABLE IF EXISTS `nfts`;
CREATE TABLE `nfts`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `address` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'user wallet address',
  `token_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'nft token id',
  `remainCount` int NULL DEFAULT 0 COMMENT 'pay fee count',
  `winnings` int NULL DEFAULT 0 COMMENT 'winning count',
  `sync_index` int NULL DEFAULT NULL COMMENT 'sync index from contract',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 372 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for winners
-- ----------------------------
DROP TABLE IF EXISTS `winners`;
CREATE TABLE `winners`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `winner_ids` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'winner nft ids seperated with (,)',
  `attend_ids` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'attend nft ids seperated with (,)',
  `lottery_count` int NULL DEFAULT NULL COMMENT 'lottery count',
  `date` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'lottery time',
  `winner_string` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 118 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
