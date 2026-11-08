-- The Camp Narache rogue, priest, mage and warlock trainers (045) had greetings copied from Alliance trainers, written
-- in Common, which Horde characters see as gibberish. Use Horde trainers' menus for the same lists, in Orcish:
-- Rwag (141, list 25), Dark Cleric Duesten (3645, list 7), Mai'ah (64, list 5), Nartok (4643, list 13).
-- Apply to the `world` database; restart worldserver.
UPDATE creature_template_gossip SET MenuID = 141  WHERE CreatureID = 8103022;
UPDATE creature_template_gossip SET MenuID = 3645 WHERE CreatureID = 8103023;
UPDATE creature_template_gossip SET MenuID = 64   WHERE CreatureID = 8103024;
UPDATE creature_template_gossip SET MenuID = 4643 WHERE CreatureID = 8103025;
UPDATE creature_trainer SET MenuID = 141,  OptionID = 0 WHERE CreatureID = 8103022;
UPDATE creature_trainer SET MenuID = 3645, OptionID = 0 WHERE CreatureID = 8103023;
UPDATE creature_trainer SET MenuID = 64,   OptionID = 0 WHERE CreatureID = 8103024;
UPDATE creature_trainer SET MenuID = 4643, OptionID = 0 WHERE CreatureID = 8103025;
