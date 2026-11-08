-- Class quests at the Sky Elf start for paladins, priests and warlocks (to the trainers from 052) and mages (to Dorii
-- Brightwhisper, who had none), like the stock ones: offered by Rorian the Dayseeker (251361) after Harmony in Balance
-- (92461) to both Sky Elf races (mask bits 32-33), level 2, Skyborne reputation (2778) as in The Way of the Hunter.
-- Copied from A Druid's Summons (9100301), no letter item or portrait. Apply to the `world` database; the client side is
-- 054_skyelf_class_letters_hotfix.sql. Restart worldserver.
DELETE FROM creature_queststarter WHERE quest BETWEEN 9100321 AND 9100324;
DELETE FROM creature_questender WHERE quest BETWEEN 9100321 AND 9100324;
DELETE FROM quest_details WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_request_items WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_offer_reward WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_template_addon WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_template_classic_level WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_classic_level WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_classic_money WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM quest_template WHERE ID BETWEEN 9100321 AND 9100324;

DROP TEMPORARY TABLE IF EXISTS tmp_q;
CREATE TEMPORARY TABLE tmp_q (ID INT UNSIGNED, cls INT UNSIGNED, sort INT, ender INT UNSIGNED,
    title VARCHAR(100), logd TEXT, descr TEXT, req TEXT, reward TEXT);
INSERT INTO tmp_q VALUES
  (9100321, 2, -141, 8103027, 'A Paladin''s Summons', 'Speak with Saraan Brightgale in Thendal Grove.',
   'While you were away dealing with our vuldren problem, Saraan Brightgale came asking after you. Saraan calls upon the Light to shield others, and believes you could learn to do the same. Go and speak with Saraan here in Thendal Grove before you head out again.',
   'The Light is with you, $N. What do you need?',
   'So Rorian sent you. Good. The winds of Zephras are harsh, $N, and our people need those who will stand between them and harm.$B$BCome to me as you grow stronger, and I will teach you to carry the Light.'),
  (9100322, 16, -262, 8103028, 'A Priest''s Summons', 'Speak with Liaara Moonbreeze in Thendal Grove.',
   'While you were away dealing with our vuldren problem, Liaara Moonbreeze came asking after you. Liaara tends to the wounded of the grove and believes you have the gift for healing. Go and speak with Liaara here in Thendal Grove before you head out again.',
   'Be at peace, $N. What can I do for you?',
   'You came. Good. To heal is to give a part of yourself to another, $N, and there are many here who will need it before the storms pass.$B$BCome to me as you grow stronger, and I will teach you what I can.'),
  (9100323, 256, -61, 8103029, 'A Warlock''s Summons', 'Speak with Vexaan Duskgale in Thendal Grove.',
   'While you were away dealing with our vuldren problem, Vexaan Duskgale came asking for you by name. I do not care for what Vexaan practices, but I will not keep you away. Speak with Vexaan here in Thendal Grove, and walk carefully.',
   'You have come, $N. Good.',
   'Rorian told you to be careful, I imagine. Rorian is right to. The fel is dangerous, $N, but power refused is only power left to our enemies.$B$BCome to me as you grow stronger, and I will teach you to bind what others fear.'),
  (9100324, 128, -161, 251379, 'A Mage''s Summons', 'Speak with Dorii Brightwhisper in Thendal Grove.',
   'While you were away dealing with our vuldren problem, Dorii Brightwhisper came asking after you. Dorii studies the arcane and believes you have a talent for it. Go and speak with Dorii here in Thendal Grove before you head out again.',
   'Ah, $N. Have you come to learn?',
   'You came. Good. The arcane answers those with the discipline to master it, $N, and our people have always had a gift for it.$B$BReturn to me as you grow stronger, and I will teach you what I can.');

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT q.* FROM quest_template q JOIN tmp_q t WHERE q.ID = 9100301;
SET @n = 9100320;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableRaces = 12884901888, c.QuestSortID = t.sort,
    c.RewardFactionID1 = 2778, c.RewardFactionValue1 = 3, c.RewardFactionOverride1 = 0,
    c.PortraitGiver = 0, c.PortraitGiverName = NULL, c.PortraitGiverText = NULL, c.LogTitle = t.title,
    c.LogDescription = t.logd, c.QuestDescription = t.descr;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT a.* FROM quest_template_addon a JOIN tmp_q t WHERE a.ID = 9100301;
SET @n = 9100320;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableClasses = t.cls, c.PrevQuestID = 92461;
INSERT INTO quest_template_addon SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO quest_details (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, VerifiedBuild)
SELECT t.ID, d.Emote1, d.Emote2, d.Emote3, d.Emote4, d.EmoteDelay1, d.EmoteDelay2, d.EmoteDelay3, d.EmoteDelay4, 0
FROM quest_details d JOIN tmp_q t WHERE d.ID = 9100301;
INSERT INTO quest_request_items (ID, EmoteOnComplete, EmoteOnIncomplete, CompletionText, VerifiedBuild)
SELECT ID, 6, 6, req, 0 FROM tmp_q;
INSERT INTO quest_offer_reward (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, RewardText, VerifiedBuild)
SELECT ID, 2, 1, 1, 0, 0, 0, 0, 0, reward, 0 FROM tmp_q;

INSERT INTO quest_template_classic_level (ID, LevelType, QuestLevel) SELECT ID, 2, 2 FROM tmp_q;
INSERT INTO quest_classic_level (ID, QuestLevel, MinLevel, MaxLevel) SELECT ID, 2, 2, 0 FROM tmp_q;

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) SELECT 251361, ID, 0 FROM tmp_q;
INSERT INTO creature_questender (id, quest, VerifiedBuild) SELECT ender, ID, 0 FROM tmp_q;
DROP TEMPORARY TABLE tmp_q;
