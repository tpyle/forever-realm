-- Run on `characters` first if any character has granted points:
--   DELETE FROM character_queststatus_rewarded WHERE quest BETWEEN 9100001 AND 9100249;
DELETE FROM quest_template WHERE ID BETWEEN 9100001 AND 9100249;
