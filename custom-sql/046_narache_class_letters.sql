-- Class quests for tauren paladins, rogues, priests, mages and warlocks in Camp Narache, like the stock notes: offered
-- by Grull Hawkwind (2980) after The Hunt Begins (747), ended at the trainers from 045, with Thunder Bluff reputation
-- (81) and no portrait. Copied from A Druid's Summons (9100301: level 1, no letter item). Apply to the `world` database;
-- the client side is 047_narache_class_letters_hotfix.sql. Restart worldserver.
DELETE FROM creature_queststarter WHERE quest BETWEEN 9100311 AND 9100315;
DELETE FROM creature_questender WHERE quest BETWEEN 9100311 AND 9100315;
DELETE FROM quest_details WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_request_items WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_offer_reward WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_template_addon WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_template_classic_level WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_classic_level WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_classic_money WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM quest_template WHERE ID BETWEEN 9100311 AND 9100315;

DROP TEMPORARY TABLE IF EXISTS tmp_q;
CREATE TEMPORARY TABLE tmp_q (ID INT UNSIGNED, cls INT UNSIGNED, sort INT, ender INT UNSIGNED,
    title VARCHAR(100), logd TEXT, descr TEXT, req TEXT, reward TEXT);
INSERT INTO tmp_q VALUES
  (9100311, 2, -141, 8103021, 'A Paladin''s Summons',
   'Speak to Ahrok Dawnhoof in Camp Narache.',
   'Ahrok Dawnhoof has asked to see you, $N. The Earth Mother gives warmth through the sun, and Ahrok has learned to carry that light into battle to shield the herd. Find Ahrok in Camp Narache before you go about any other business here.',
   'The sun is with you, $N. What do you need?',
   'So Grull sent you. Good. The sun watches over the herd, $N, and those who bear its light stand between our people and harm.$B$BCome to me as you grow stronger, and I will teach you to carry it.'),
  (9100312, 8, -162, 8103022, 'A Rogue''s Summons',
   'Speak to Kesh Swiftstride in Camp Narache.',
   'Kesh Swiftstride came by asking after you, $N. Not all hunts are won by strength; some are won by never being seen. Kesh believes you have the knack for it. Find Kesh in Camp Narache before you go about any other business here.',
   'Quietly now, $N. What do you need?',
   'You found me, which is a start. Our people are not known for their subtlety, $N, but the plains reward patience, and a blade in the dark ends a fight before it begins.$B$BCome to me as you grow stronger, and I will teach you what I can.'),
  (9100313, 16, -262, 8103023, 'A Priest''s Summons',
   'Speak to Yanna Brightmane just east of Camp Narache.',
   'Yanna Brightmane has been asking for you, $N. Yanna tends to the spirits of the wounded and believes you could learn to do the same. You will find Yanna just east of the camp; go before you go about any other business here.',
   'Be at peace, $N. What can I do for you?',
   'So Grull found you. Good. To heal is to give a part of yourself to another, $N, and there is no greater gift to the herd.$B$BCome to me as you grow stronger, and I will teach you what I can.'),
  (9100314, 128, -161, 8103024, 'A Mage''s Summons',
   'Speak to Tarhi Starhorn by the kodo skeleton south of Camp Narache.',
   'Tarhi Starhorn studies the arcane, $N, and says you might have a gift for it too. Most of our people are wary of such things, but I will not stand in your way. Look for Tarhi by the kodo skeleton south of the camp before you go about any other business here.',
   'Ah, $N. Have you come to learn?',
   'You came. Good. The arcane is not the way of the Earth Mother, $N, and many will look at you warily for it. Learn it well, and use it for the herd.$B$BReturn to me as you grow stronger, and I will teach you what I can.'),
  (9100315, 256, -61, 8103025, 'A Warlock''s Summons',
   'Speak to Grath Ashmane behind the graveyard near Camp Narache.',
   'There is one called Grath Ashmane behind the graveyard, $N, and Grath has asked for you by name. I do not trust what Grath practices, but I will not keep you away. Go, and walk carefully.',
   'You have come, $N. Good.',
   'Grull told you to be careful, did he not? He is right to. The fel is dangerous, $N, but our enemies will use it whether we do or not.$B$BCome to me as you grow stronger, and I will teach you to bind what others fear.');

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT q.* FROM quest_template q JOIN tmp_q t WHERE q.ID = 9100301;
SET @n = 9100310;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableRaces = 32, c.QuestSortID = t.sort, c.RewardFactionID1 = 81,
    c.PortraitGiver = 0, c.PortraitGiverName = NULL, c.PortraitGiverText = NULL, c.LogTitle = t.title,
    c.LogDescription = t.logd, c.QuestDescription = t.descr;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT a.* FROM quest_template_addon a JOIN tmp_q t WHERE a.ID = 9100301;
SET @n = 9100310;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableClasses = t.cls, c.PrevQuestID = 747;
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

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) SELECT 2980, ID, 0 FROM tmp_q;
INSERT INTO creature_questender (id, quest, VerifiedBuild) SELECT ender, ID, 0 FROM tmp_q;
DROP TEMPORARY TABLE tmp_q;
