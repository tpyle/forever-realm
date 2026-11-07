-- Removes the Horde paladin trainers.
DELETE FROM creature WHERE guid IN (26300001, 26300002);
DELETE FROM creature_trainer WHERE CreatureID IN (8103001, 8103002);
DELETE FROM creature_template_gossip WHERE CreatureID IN (8103001, 8103002);
DELETE FROM creature_equip_template WHERE CreatureID IN (8103001, 8103002);
DELETE FROM creature_template_difficulty WHERE Entry IN (8103001, 8103002);
DELETE FROM creature_template_model WHERE CreatureID IN (8103001, 8103002);
DELETE FROM creature_template WHERE entry IN (8103001, 8103002);
