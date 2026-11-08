-- Class quests for undead hunters, shamans and druids in Deathknell, like the stock scrolls: offered by Shadow Priest
-- Sarvis (1569) after The Mindless Ones (364), ended at the trainers from 041, with Undercity reputation (68) and no
-- portrait. Copied from A Druid's Summons (9100301: level 1, no letter item). Apply to the `world` database; the client
-- side is 043_deathknell_class_letters_hotfix.sql. Restart worldserver.
DELETE FROM creature_queststarter WHERE quest BETWEEN 9100308 AND 9100310;
DELETE FROM creature_questender WHERE quest BETWEEN 9100308 AND 9100310;
DELETE FROM quest_details WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_request_items WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_offer_reward WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_template_addon WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_template_classic_level WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_classic_level WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_classic_money WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM quest_template WHERE ID BETWEEN 9100308 AND 9100310;

DROP TEMPORARY TABLE IF EXISTS tmp_q;
CREATE TEMPORARY TABLE tmp_q (ID INT UNSIGNED, cls INT UNSIGNED, sort INT, ender INT UNSIGNED,
    npc VARCHAR(100), title VARCHAR(100), place VARCHAR(100), descr TEXT, req TEXT, reward TEXT);
INSERT INTO tmp_q VALUES
  (9100308, 4, -261, 8103018, 'Edric Thornwood', 'A Hunter''s Summons', '',
   'Edric Thornwood hunted these woods long before the plague, $N, and death has not dulled his eye. He believes you can learn to do the same. Find him in Deathknell before you go about any other business here.',
   'You have the look of a hunter, $N. What do you need?',
   'So Sarvis sent you. Good. The beasts of Tirisfal fear what we have become, $N, but fear can be turned to use. A steady hand and a patient eye are all a hunter needs.$B$BCome to me as you grow stronger, and I will teach you what I can.'),
  (9100309, 64, -82, 8103019, 'Mordecai Vale', 'A Shaman''s Summons', '',
   'Mordecai Vale claims the elements still answer him, $N, though he no longer draws breath. He has asked for you. Find him in Deathknell before you go about any other business here.',
   'The spirits said you would come, $N. What do you need?',
   'There you are. The living say the elements turn from the dead, $N. They are wrong; the spirits care only whether you listen.$B$BIt is not an easy path. Return to me as you grow, and I will teach you to call on them.'),
  (9100310, 1024, -263, 8103020, 'Agatha Fenwick', 'A Druid''s Summons', '',
   'Agatha Fenwick has been asking after you, $N. She speaks of the wild as though it had never turned its back on us. Find her in Deathknell before you go about any other business here.',
   'Well met, $N. Is there something I can do for you?',
   'So Sarvis found you. Good. The wild does not ask what we were, $N, only what we can become. Even here, among the rot, things grow.$B$BCome to me as you grow stronger, and I will teach you the old ways.');

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT q.* FROM quest_template q JOIN tmp_q t WHERE q.ID = 9100301;
SET @n = 9100307;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableRaces = 16, c.QuestSortID = t.sort, c.RewardFactionID1 = 68,
    c.PortraitGiver = 0, c.PortraitGiverName = NULL, c.PortraitGiverText = NULL, c.LogTitle = t.title,
    c.LogDescription = CONCAT('Speak to ', t.npc, ' in Deathknell.'), c.QuestDescription = t.descr;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT a.* FROM quest_template_addon a JOIN tmp_q t WHERE a.ID = 9100301;
SET @n = 9100307;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableClasses = t.cls, c.PrevQuestID = 364;
INSERT INTO quest_template_addon SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO quest_details (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, VerifiedBuild)
SELECT t.ID, d.Emote1, d.Emote2, d.Emote3, d.Emote4, d.EmoteDelay1, d.EmoteDelay2, d.EmoteDelay3, d.EmoteDelay4, 0
FROM quest_details d JOIN tmp_q t WHERE d.ID = 9100301;
INSERT INTO quest_request_items (ID, EmoteOnComplete, EmoteOnIncomplete, CompletionText, VerifiedBuild)
SELECT ID, 6, 6, req, 0 FROM tmp_q;
INSERT INTO quest_offer_reward (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, RewardText, VerifiedBuild)
SELECT ID, 2, 1, 1, 0, 0, 0, 0, 0, reward, 0 FROM tmp_q;

INSERT INTO quest_template_classic_level (ID, LevelType, QuestLevel) SELECT ID, 2, 1 FROM tmp_q;
INSERT INTO quest_classic_level (ID, QuestLevel, MinLevel, MaxLevel) SELECT ID, 1, 1, 0 FROM tmp_q;
INSERT INTO quest_classic_money (ID, RewardMoney, RewardMoneyMaxLevel) SELECT ID, 0, 30 FROM tmp_q;

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) SELECT 1569, ID, 0 FROM tmp_q;
INSERT INTO creature_questender (id, quest, VerifiedBuild) SELECT ender, ID, 0 FROM tmp_q;
DROP TEMPORARY TABLE tmp_q;
