-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300012;
DELETE FROM creature_trainer WHERE CreatureID = 8103011;
DELETE FROM creature_template_gossip WHERE CreatureID = 8103011;
DELETE FROM creature_equip_template WHERE CreatureID = 8103011;
DELETE FROM creature_template_difficulty WHERE Entry = 8103011;
DELETE FROM creature_template_model WHERE CreatureID = 8103011;
DELETE FROM creature_template WHERE entry = 8103011;
