-- Apply to the `world` database; restart worldserver.
DELETE FROM creature WHERE guid BETWEEN 26300019 AND 26300021;
DELETE FROM creature_trainer WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_gossip WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_equip_template WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_difficulty WHERE Entry BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template_model WHERE CreatureID BETWEEN 8103018 AND 8103020;
DELETE FROM creature_template WHERE entry BETWEEN 8103018 AND 8103020;
