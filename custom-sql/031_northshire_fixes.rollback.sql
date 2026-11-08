-- Apply to the `world` database; restart worldserver. Restores 027-029 as first applied (texts: re-run 029 instead).
UPDATE creature_trainer SET TrainerID = 17, MenuID = 4508 WHERE CreatureID = 8103011;
UPDATE creature_template_gossip SET MenuID = 4508 WHERE CreatureID = 8103011;
UPDATE creature_trainer SET TrainerID = 10, MenuID = 5123 WHERE CreatureID = 8103012;
UPDATE creature_template_gossip SET MenuID = 5123 WHERE CreatureID = 8103012;
UPDATE quest_template SET QuestSortID = -161 WHERE ID IN (9100301, 9100302);
DELETE FROM quest_template_classic_level WHERE ID IN (9100301, 9100302);
DELETE FROM quest_classic_level WHERE ID IN (9100301, 9100302);
DELETE FROM quest_classic_money WHERE ID IN (9100301, 9100302);
