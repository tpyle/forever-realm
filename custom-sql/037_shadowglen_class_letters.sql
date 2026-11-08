-- Class quests for night elf paladins, shamans, mages and warlocks in Shadowglen, like the stock sigils: offered by
-- Conservator Ilthalaine (2079) after The Balance of Nature (456), ended at the trainers from 036. Copied from A Druid's
-- Summons (9100301: level 1, no letter item). Apply to the `world` database; the client side is
-- 038_shadowglen_class_letters_hotfix.sql. Restart worldserver.
DELETE FROM creature_queststarter WHERE quest BETWEEN 9100304 AND 9100307;
DELETE FROM creature_questender WHERE quest BETWEEN 9100304 AND 9100307;
DELETE FROM quest_details WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_request_items WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_offer_reward WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_template_addon WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_template_classic_level WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_classic_level WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_classic_money WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM quest_template WHERE ID BETWEEN 9100304 AND 9100307;

DROP TEMPORARY TABLE IF EXISTS tmp_q;
CREATE TEMPORARY TABLE tmp_q (ID INT UNSIGNED, cls INT UNSIGNED, sort INT, ender INT UNSIGNED, display INT UNSIGNED,
    npc VARCHAR(100), title VARCHAR(100), place VARCHAR(100), descr TEXT, req TEXT, reward TEXT);
INSERT INTO tmp_q VALUES
  (9100304, 2, -141, 8103014, 1896, 'Thalric Dawnleaf', 'A Paladin''s Summons', 'inside Aldrassil',
   'Thalric Dawnleaf has asked for you, $N. Few of our people walk the path of the Light, but he believes you may be one of them. Seek him inside Aldrassil before you go about any other business here.',
   'Well met, $N. Elune''s light be with you.',
   'So the Conservator sent you. Good. Our people have long trusted the moon and the wild, $N, but the Light answers those who would shield others, whatever their blood.$B$BCome to me as you grow stronger, and I will teach you to call upon it.'),
  (9100305, 64, -82, 8103015, 2458, 'Ilyran Stormbough', 'A Shaman''s Summons', 'at the foot of Aldrassil',
   'Ilyran Stormbough came to me speaking of restless spirits, $N, and of you. The elements, it seems, have taken an interest in you. Find him at the foot of Aldrassil before you go about any other business here.',
   'The winds said you would come, $N. What do you need?',
   'There you are. Earth, fire, water and air stir across Teldrassil, $N, and they have chosen you to speak with them.$B$BIt is not an easy path. Return to me as you grow, and I will teach you to call on them.'),
  (9100306, 128, -161, 8103016, 1728, 'Sylwen Starweaver', 'A Mage''s Summons', 'inside Aldrassil',
   'Sylwen Starweaver asked me to send you to her once you were done here, $N. She studies the arcane, an art our people once paid dearly for, and she believes you have the gift. Seek her inside Aldrassil before you go about any other business here.',
   'Ah, $N. Have you come to learn?',
   'You came. Good. Our people remember what the arcane cost us, $N, and many will look at you warily for studying it. Mastery and caution are the same lesson.$B$BReturn to me as you grow stronger, and I will teach you what I can.'),
  (9100307, 256, -61, 8103017, 4861, 'Naeryth Duskshade', 'A Warlock''s Summons', 'inside Aldrassil',
   'There is one inside Aldrassil who calls herself Naeryth Duskshade, and she has asked for you by name, $N. I do not trust what she practices, but I will not keep you from her. Go, and walk carefully.',
   'You have come, $N. Good.',
   'The Conservator told you to be careful, did he not? He is right to. The fel is dangerous, $N, but power refused is only power left to our enemies.$B$BCome to me as you grow stronger, and I will teach you to bind what others fear.');

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT q.* FROM quest_template q JOIN tmp_q t WHERE q.ID = 9100301;
SET @n = 9100303;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableRaces = 8, c.QuestSortID = t.sort, c.PortraitGiver = t.display,
    c.PortraitGiverName = t.npc, c.PortraitGiverText = CONCAT(t.npc, ' can be found ', t.place, '.'), c.LogTitle = t.title,
    c.LogDescription = CONCAT('Speak to ', t.npc, ' ', t.place, ' in Shadowglen.'), c.QuestDescription = t.descr;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT a.* FROM quest_template_addon a JOIN tmp_q t WHERE a.ID = 9100301;
SET @n = 9100303;
UPDATE tmp_clone SET ID = (@n := @n + 1);
UPDATE tmp_clone c JOIN tmp_q t ON t.ID = c.ID SET c.AllowableClasses = t.cls, c.PrevQuestID = 456;
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

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) SELECT 2079, ID, 0 FROM tmp_q;
INSERT INTO creature_questender (id, quest, VerifiedBuild) SELECT ender, ID, 0 FROM tmp_q;
DROP TEMPORARY TABLE tmp_q;
