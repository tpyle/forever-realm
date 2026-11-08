-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300028 AND 26300030;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103027 AND 8103029;
DELETE FROM creature_template WHERE entry BETWEEN 8103027 AND 8103029;
DELETE FROM conditions WHERE SourceTypeOrReferenceId = 15 AND SourceGroup IN (8103028, 8103029);
DELETE FROM gossip_menu_option WHERE MenuID IN (8103028, 8103029);
DELETE FROM gossip_menu WHERE MenuID IN (8103028, 8103029);
UPDATE creature_template SET faction = 3599 WHERE entry IN (251374, 252382, 254082);
UPDATE creature_template SET faction = 3600 WHERE entry = 251379;
