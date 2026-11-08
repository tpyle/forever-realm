-- Class quests for human druids and shamans in Northshire, like the other classes' letters: offered by Marshal McBride
-- (197) after Kobold Camp Cleanup (7), ended at the Northshire trainers from 027/028. Cloned from Glyphic Letter (3104,
-- the mage one) without its letter item. Apply to the `world` database; the client side is 030_northshire_class_letters_hotfix.sql.
-- Restart worldserver.
DELETE FROM creature_queststarter WHERE quest IN (9100301, 9100302);
DELETE FROM creature_questender WHERE quest IN (9100301, 9100302);
DELETE FROM quest_details WHERE ID IN (9100301, 9100302);
DELETE FROM quest_request_items WHERE ID IN (9100301, 9100302);
DELETE FROM quest_offer_reward WHERE ID IN (9100301, 9100302);
DELETE FROM quest_template_addon WHERE ID IN (9100301, 9100302);
DELETE FROM quest_template WHERE ID IN (9100301, 9100302);

DROP TEMPORARY TABLE IF EXISTS tmp_clone;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM quest_template WHERE ID = 3104;
INSERT INTO tmp_clone SELECT * FROM quest_template WHERE ID = 3104;
UPDATE tmp_clone SET ID = 9100301 LIMIT 1;
UPDATE tmp_clone SET ID = 9100302 WHERE ID = 3104;
UPDATE tmp_clone SET StartItem = 0, PortraitGiver = 5551, PortraitGiverName = 'Corwin Oakheart',
    PortraitGiverText = 'Corwin Oakheart can be found inside Northshire Abbey.',
    LogTitle = 'A Druid''s Summons',
    LogDescription = 'Speak to Corwin Oakheart inside Northshire Abbey.',
    QuestDescription = 'Corwin Oakheart, a druid who keeps to himself inside the Abbey, asked me to send you his way once you were done with the kobolds, $N. Few in Elwynn follow the old ways of the wild, so he will be glad to see you. Find him before you go about any other business here.'
    WHERE ID = 9100301;
UPDATE tmp_clone SET StartItem = 0, PortraitGiver = 5074, PortraitGiverName = 'Brannoc Stormward',
    PortraitGiverText = 'Brannoc Stormward can be found inside Northshire Abbey.',
    LogTitle = 'A Shaman''s Summons',
    LogDescription = 'Speak to Brannoc Stormward inside Northshire Abbey.',
    QuestDescription = 'Brannoc Stormward came all the way to the Abbey asking after you, $N. He says the elements have taken an interest in you, and he means to teach you to answer them. Find him inside the Abbey before you go about any other business here.'
    WHERE ID = 9100302;
INSERT INTO quest_template SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

CREATE TEMPORARY TABLE tmp_clone SELECT * FROM quest_template_addon WHERE ID = 3104;
INSERT INTO tmp_clone SELECT * FROM quest_template_addon WHERE ID = 3104;
UPDATE tmp_clone SET ID = 9100301, AllowableClasses = 1024 LIMIT 1;
UPDATE tmp_clone SET ID = 9100302, AllowableClasses = 64 WHERE ID = 3104;
UPDATE tmp_clone SET ProvidedItemCount = 0;
INSERT INTO quest_template_addon SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;

INSERT INTO quest_details (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, VerifiedBuild)
SELECT q.ID, d.Emote1, d.Emote2, d.Emote3, d.Emote4, d.EmoteDelay1, d.EmoteDelay2, d.EmoteDelay3, d.EmoteDelay4, 0
FROM quest_details d JOIN (SELECT 9100301 AS ID UNION SELECT 9100302) q WHERE d.ID = 3104;

INSERT INTO quest_request_items (ID, EmoteOnComplete, EmoteOnIncomplete, CompletionText, VerifiedBuild) VALUES
  (9100301, 6, 6, 'Well met, $N. Is there something I can do for you?', 0),
  (9100302, 6, 6, 'The winds said you would come, $N. What do you need?', 0);

INSERT INTO quest_offer_reward (ID, Emote1, Emote2, Emote3, Emote4, EmoteDelay1, EmoteDelay2, EmoteDelay3, EmoteDelay4, RewardText, VerifiedBuild) VALUES
  (9100301, 2, 1, 1, 0, 0, 0, 0, 0, 'So the Marshal found you. Good. There are not many of us among the humans, $N, and the wild does not call to just anyone.$B$BThe forest, the bear and the cat will all have lessons for you. Come to me as you grow stronger, and I will teach you what I can.', 0),
  (9100302, 2, 1, 1, 0, 0, 0, 0, 0, 'Ah, there you are. The spirits of earth, fire, water and air are restless, $N, and they have chosen you to speak with them.$B$BIt is not an easy path. Return to me as you grow, and I will teach you to call on them. In time you will need totems for that, and the earth spirits of Dun Morogh can help you with the first of them.', 0);

INSERT INTO creature_queststarter (id, quest, VerifiedBuild) VALUES (197, 9100301, 0), (197, 9100302, 0);
INSERT INTO creature_questender (id, quest, VerifiedBuild) VALUES (8103011, 9100301, 0), (8103012, 9100302, 0);
