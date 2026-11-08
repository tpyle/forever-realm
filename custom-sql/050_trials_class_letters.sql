-- The missing class quests in the Valley of Trials, offered by Gornek (3143) after Cutting Teeth (788) like the stock
-- parchments (orcs, Orgrimmar reputation 76) and tablets (trolls, Darkspear reputation 530): orc priest (to Ken'jai),
-- orc and troll paladin (to Korgath the Redeemed, 8103001) and orc and troll druid (to Thrag Earthroot, 049). One quest
-- per race so each gets its own faction. Copied from A Druid's Summons (9100301: level 1, no letter item), no portrait.
-- Apply to the `world` database; the client side is 051_trials_class_letters_hotfix.sql. Restart worldserver.
DELETE FROM creature_queststarter WHERE quest BETWEEN 9100316 AND 9100320;
DELETE FROM creature_questender WHERE quest BETWEEN 9100316 AND 9100320;
DELETE FROM quest_details WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_request_items WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_offer_reward WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_template_addon WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_template_classic_level WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_classic_level WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_classic_money WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM quest_template WHERE ID BETWEEN 9100316 AND 9100320;

SET @priest_d = 'Ken''jai has asked to see you, $N. The Darkspear''s priest tends to the spirits of the wounded here, and believes you could learn to do the same. Find Ken''jai outside the Den before you go about any other business here.';
SET @priest_q = 'You be lookin'' for wisdom, $N?';
SET @priest_r = 'Gornek sent you, did he? Good. Healin'' is a gift, $N, and not one the Horde can spare. The spirits be watchin'' how you use it.$B$BCome back to me as you grow, and I teach you what I can.';
SET @pal_d = 'Korgath the Redeemed has asked for you, $N. He walks a strange path for one of the Horde, calling on the Light to shield his brothers and sisters in battle, and he believes you could walk it too. Find him in the Valley of Trials before you go about any other business here.';
SET @pal_q = 'Well met, $N. What brings you to me?';
SET @pal_r = 'So Gornek sent you. Good. Many of our people still distrust the Light, $N, for the humans who wielded it against us. But the Light cares nothing for whose hands call upon it, only for what they protect.$B$BCome to me as you grow stronger, and I will teach you to carry it.';
SET @dru_d = 'Thrag Earthroot came down from the hills asking after you, $N. He follows the ways of the wild, as the tauren do, and he says you might have the gift for it. Find him just outside the camp before you go about any other business here.';
SET @dru_q = 'Well met, $N. Is there something I can do for you?';
SET @dru_r = 'So Gornek found you. Good. Durotar is a harsh land, $N, but even here the wild has lessons for those who listen: the boar, the scorpid and the raptor all endure.$B$BCome to me as you grow stronger, and I will teach you the old ways.';

DROP TEMPORARY TABLE IF EXISTS tmp_q;
CREATE TEMPORARY TABLE tmp_q (ID INT UNSIGNED, race BIGINT UNSIGNED, rep INT, cls INT UNSIGNED, sort INT, ender INT UNSIGNED,
    title VARCHAR(100), logd TEXT, descr TEXT, req TEXT, reward TEXT);
INSERT INTO tmp_q VALUES
  (9100316,   2,  76,   16, -262,    3707, 'A Priest''s Summons',  'Speak to Ken''jai outside the Den in the Valley of Trials.', @priest_d, @priest_q, @priest_r),
  (9100317,   2,  76,    2, -141, 8103001, 'A Paladin''s Summons', 'Speak to Korgath the Redeemed in the Valley of Trials.', @pal_d, @pal_q, @pal_r),
  (9100318, 128, 530,    2, -141, 8103001, 'A Paladin''s Summons', 'Speak to Korgath the Redeemed in the Valley of Trials.', @pal_d, @pal_q, @pal_r),
  (9100319,   2,  76, 1024, -263, 8103026, 'A Druid''s Summons',   'Speak to Thrag Earthroot just outside the camp in the Valley of Trials.', @dru_d, @dru_q, @dru_r),
  (9100320, 128, 530, 1024, -263, 8103026, 'A Druid''s Summons',   'Speak to Thrag Earthroot just outside the camp in the Valley of Trials.', @dru_d, @dru_q, @dru_r);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT q.* FROM quest_template q JOIN tmp_q t WHERE q.ID = 9100301;
SET @n = 9100315;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableRaces = t.race, c.QuestSortID = t.sort, c.RewardFactionID1 = t.rep,
    c.PortraitGiver = 0, c.PortraitGiverName = NULL, c.PortraitGiverText = NULL, c.LogTitle = t.title,
    c.LogDescription = t.logd, c.QuestDescription = t.descr;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT a.* FROM quest_template_addon a JOIN tmp_q t WHERE a.ID = 9100301;
SET @n = 9100315;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableClasses = t.cls, c.PrevQuestID = 788;
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

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) SELECT 3143, ID, 0 FROM tmp_q;
INSERT INTO creature_questender (id, quest, VerifiedBuild) SELECT ender, ID, 0 FROM tmp_q;
DROP TEMPORARY TABLE tmp_q;
