-- Permanent bonus stats per character for .bonusstats (cs_bonusstats.cpp). Apply to the `characters`
-- database; no restart needed, but the binary with cs_bonusstats has to be running to use it.
-- `stat` is the command's stat key (see cs_bonusstats.cpp), `amount` the bonus in points or rating.
CREATE TABLE IF NOT EXISTS character_bonus_stat (
    guid   BIGINT UNSIGNED  NOT NULL,
    stat   TINYINT UNSIGNED NOT NULL,
    amount INT UNSIGNED     NOT NULL,
    PRIMARY KEY (guid, stat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
