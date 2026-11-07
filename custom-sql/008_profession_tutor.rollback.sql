-- Removes Fizzle Everhand. Professions already learned from him are kept.
DELETE FROM creature WHERE guid IN (26300003, 26300004);
DELETE FROM creature_template_difficulty WHERE Entry = 8103003;
DELETE FROM creature_template_model WHERE CreatureID = 8103003;
DELETE FROM creature_template WHERE entry = 8103003;
