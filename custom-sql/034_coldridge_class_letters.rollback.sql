-- Apply to the `world` database; restart worldserver.
UPDATE quest_template SET AllowableRaces = 64 WHERE ID IN (3114, 3115);
UPDATE quest_template SET AllowableRaces = 4 WHERE ID IN (3107, 3108, 98581);

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
