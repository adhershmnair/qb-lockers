CREATE TABLE `lockers` (
	`id` INT(20) NOT NULL AUTO_INCREMENT,
	`lockerid` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`locker` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
	`citizenid` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`password` VARCHAR(20) NOT NULL DEFAULT '0000' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `lockerid` (`lockerid`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;
