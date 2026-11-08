-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300015 AND 26300018;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103014 AND 8103017;
DELETE FROM creature_template WHERE entry BETWEEN 8103014 AND 8103017;
