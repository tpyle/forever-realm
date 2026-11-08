-- Class letters in Coldridge Valley for every dwarf and gnome class. Sten Stoutarm (658) offers them after Dwarven
-- Outfitters (179); stock had runes for dwarves and memorandums for gnomes, each missing some classes.
-- Apply to the `world` database; the client side of the new quest is 035_coldridge_class_letters_hotfix.sql.
-- Restart worldserver.

-- The other race's letter opens to both (dwarf 4, gnome 64): Consecrated Rune (paladin), Etched Rune (hunter) and
-- Archaic Rune (shaman) for gnomes, Glyphic Memorandum (mage) and Tainted Memorandum (warlock) for dwarves.
UPDATE quest_template SET AllowableRaces = AllowableRaces | 68 WHERE ID IN (3107, 3108, 98581, 3114, 3115);

-- Druids: a new quest for both races, copied from A Druid's Summons (9100301, Northshire), ended at Durgan Mossbeard (033).
DELETE FROM creature_queststarter WHERE quest = 9100303;
DELETE FROM creature_questender WHERE quest = 9100303;
DELETE FROM quest_details WHERE ID = 9100303;
DELETE FROM quest_request_items WHERE ID = 9100303;
DELETE FROM quest_offer_reward WHERE ID = 9100303;
DELETE FROM quest_template_addon WHERE ID = 9100303;
DELETE FROM quest_template_classic_level WHERE ID = 9100303;
DELETE FROM quest_classic_level WHERE ID = 9100303;
DELETE FROM quest_classic_money WHERE ID = 9100303;
DELETE FROM quest_template WHERE ID = 9100303;

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM quest_template WHERE ID = 9100301;
UPDATE tmp_clone SET ID = 9100303, AllowableRaces = 68, PortraitGiver = 3433, PortraitGiverName = 'Durgan Mossbeard',
    PortraitGiverText = 'Durgan Mossbeard can be found inside Anvilmar.',
    LogTitle = 'A Druid''s Summons',
    LogDescription = 'Speak to Durgan Mossbeard inside Anvilmar above Coldridge Valley.',
    QuestDescription = 'A fellow by the name of Durgan Mossbeard came down from the hills askin'' after ye, $N. Says he follows the old ways of the wild, and that ye might have the knack for it too. Can''t say I know much about such things, but he seemed keen. Go find him inside Anvilmar when you''ve a chance.';
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM quest_template_addon WHERE ID = 9100301;
UPDATE tmp_clone SET ID = 9100303, PrevQuestID = 179;
INSERT INTO quest_template_addon SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO quest_details (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, VerifiedBuild)
SELECT 9100303, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, 0 FROM quest_details WHERE ID = 9100301;

INSERT INTO quest_request_items (ID, EmoteOnComplete, EmoteOnIncomplete, CompletionText, VerifiedBuild) VALUES
  (9100303, 6, 6, 'Well met, $N. What brings ye to me?', 0);

INSERT INTO quest_offer_reward (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, RewardText, VerifiedBuild) VALUES
  (9100303, 2, 1, 1, 0, 0, 0, 0, 0, 'So Sten passed on my message. Good. Most of our folk look to stone and steel, $N, but the snow, the pines and the bears of these mountains have their own lessons to teach.$B$BCome to me as you grow stronger, and I will teach you what I can of the wild.', 0);

INSERT INTO quest_template_classic_level (ID, LevelType, QuestLevel) VALUES (9100303, 2, 1);
INSERT INTO quest_classic_level (ID, QuestLevel, MinLevel, MaxLevel) VALUES (9100303, 1, 1, 0);
INSERT INTO quest_classic_money (ID, RewardMoney, RewardMoneyMaxLevel) VALUES (9100303, 0, 30);

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) VALUES (658, 9100303, 0);
INSERT INTO creature_questender (id, quest, VerifiedBuild) VALUES (8103013, 9100303, 0);
