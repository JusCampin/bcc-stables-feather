CREATE TABLE IF NOT EXISTS `player_horses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `uuid` UUID NOT NULL DEFAULT UUID(),
  `character_id` INT(11) NOT NULL,
  `selected` INT(11) NOT NULL DEFAULT 0,
  `name` VARCHAR(255) NOT NULL,
  `model` VARCHAR(255) NOT NULL,
  `gender` ENUM('male', 'female') DEFAULT 'male',
  `components` VARCHAR(255) NOT NULL DEFAULT '{}',
  `health` INT(11) NOT NULL DEFAULT 100,
  `stamina` INT(11) NOT NULL DEFAULT 100,
  `xp` INT(11) NOT NULL DEFAULT 0,
  `captured` INT(11) NOT NULL DEFAULT 0,
  `dead` INT(11) NOT NULL DEFAULT 0,
  `born` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `items`(`name`, `display_name`, `description`, `max_quantity`, `max_stack_size`, `weight`, `usable`, `category_id`, `type`)
VALUES
  ('oil_lantern', 'Oil Lantern', 'A portable light source.', 1, 1, 5, 1, 1, 'item_item'),
  ('consumable_horse_reviver', 'Horse Reviver', 'Curative compound for injured horse.', 3, 5, 2, 1, 1, 'item_item'),
  ('consumable_haycube', 'Haycube', 'A compact cube of hay.', 100, 20, 1, 1, 1, 'item_item'),
  ('consumable_apple', 'Apple', 'A juicy and delicious fruit.', 100, 20, 1, 1, 1, 'item_item'),
  ('consumable_carrots', 'Carrots', 'An orange root vegetable commonly used in cooking.', 100, 20, 1, 1, 1, 'item_item')
ON DUPLICATE KEY UPDATE
  `name`=VALUES(`name`),
  `display_name`=VALUES(`display_name`),
  `description`=VALUES(`description`),
  `max_quantity`=VALUES(`max_quantity`),
  `max_stack_size`=VALUES(`max_stack_size`),
  `weight`=VALUES(`weight`),
  `usable`=VALUES(`usable`),
  `category_id`=VALUES(`category_id`),
  `type`=VALUES(`type`);
