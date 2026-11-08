-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid = 26300027;
DELETE FROM creature_trainer WHERE CreatureID = 8103026;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103026;
DELETE FROM creature_equip_template WHERE CreatureID = 8103026;
DELETE FROM creature_template_difficulty WHERE Entry = 8103026;
DELETE FROM creature_template_model WHERE CreatureID = 8103026;
DELETE FROM creature_template WHERE entry = 8103026;
UPDATE creature_trainer SET TrainerID = 29 WHERE CreatureID = 8103001;
