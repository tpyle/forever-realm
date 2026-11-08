-- Apply to the `world` database; restart worldserver. Restores the menus from 045.
UPDATE creature_template_gossip SET MenuID = 4690 WHERE CreatureID = 8103022;
UPDATE creature_template_gossip SET MenuID = 4679 WHERE CreatureID = 8103023;
UPDATE creature_template_gossip SET MenuID = 4660 WHERE CreatureID = 8103024;
UPDATE creature_template_gossip SET MenuID = 1503 WHERE CreatureID = 8103025;
UPDATE creature_trainer SET MenuID = 4690, OptionID = 0 WHERE CreatureID = 8103022;
UPDATE creature_trainer SET MenuID = 4679, OptionID = 0 WHERE CreatureID = 8103023;
UPDATE creature_trainer SET MenuID = 4660, OptionID = 0 WHERE CreatureID = 8103024;
UPDATE creature_trainer SET MenuID = 1503, OptionID = 0 WHERE CreatureID = 8103025;
