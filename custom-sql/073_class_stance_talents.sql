-- Class stance talents (core ClassStance.h, the ForeverStances addon): the talents a character has picked in the trees of its
-- learned stance classes, a separate pool of points per class. The real class's talents stay in character_trait_entry.
-- Apply to the `characters` database; no restart needed (read at login).
CREATE TABLE IF NOT EXISTS character_class_stance_talent (
  guid BIGINT UNSIGNED NOT NULL,
  class TINYINT UNSIGNED NOT NULL,
  talent INT UNSIGNED NOT NULL,       -- Talent.db2 ID
  `rank` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (guid, talent),
  KEY idx_guid_class (guid, class)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
