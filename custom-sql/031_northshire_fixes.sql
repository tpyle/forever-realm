-- Corrections to 027-029 after testing. Apply to the `world` database; restart worldserver.
-- Trainers: the starting-zone lists (spells up to level 6) instead of the capital ones: druid list 1233 and menu 4688
-- (Mardant Strongoak, Shadowglen), shaman list 11 and menu 4652 (Shikrik, Valley of Trials).
UPDATE creature_trainer SET TrainerID = 1233, MenuID = 4688 WHERE CreatureID = 8103011;
UPDATE creature_template_gossip SET MenuID = 4688 WHERE CreatureID = 8103011;
UPDATE creature_trainer SET TrainerID = 11, MenuID = 4652 WHERE CreatureID = 8103012;
UPDATE creature_template_gossip SET MenuID = 4652 WHERE CreatureID = 8103012;

-- Quests: the quest log category of their class (it was Mage, from Glyphic Letter), the trainers' real spot, and the
-- Classic level rows the client shows (level 1, like the other letters).
UPDATE quest_template SET QuestSortID = -263,
    LogDescription = 'Speak to Corwin Oakheart by the stables outside Northshire Abbey.',
    PortraitGiverText = 'Corwin Oakheart can be found by the stables outside Northshire Abbey.',
    QuestDescription = 'Corwin Oakheart, a druid who keeps to himself by the Abbey stables, asked me to send you his way once you were done with the kobolds, $N. Few in Elwynn follow the old ways of the wild, so he will be glad to see you. Find him before you go about any other business here.'
    WHERE ID = 9100301;
UPDATE quest_template SET QuestSortID = -82,
    LogDescription = 'Speak to Brannoc Stormward by the stables outside Northshire Abbey.',
    PortraitGiverText = 'Brannoc Stormward can be found by the stables outside Northshire Abbey.',
    QuestDescription = 'Brannoc Stormward came all the way to the Abbey asking after you, $N. He says the elements have taken an interest in you, and he means to teach you to answer them. You will find him by the stables outside; see him before you go about any other business here.'
    WHERE ID = 9100302;

DELETE FROM quest_template_classic_level WHERE ID IN (9100301, 9100302);
INSERT INTO quest_template_classic_level (ID, LevelType, QuestLevel) VALUES (9100301, 2, 1), (9100302, 2, 1);
DELETE FROM quest_classic_level WHERE ID IN (9100301, 9100302);
INSERT INTO quest_classic_level (ID, QuestLevel, MinLevel, MaxLevel) VALUES (9100301, 1, 1, 0), (9100302, 1, 1, 0);
DELETE FROM quest_classic_money WHERE ID IN (9100301, 9100302);
INSERT INTO quest_classic_money (ID, RewardMoney, RewardMoneyMaxLevel) VALUES (9100301, 0, 30), (9100302, 0, 30);
