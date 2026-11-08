-- Apply to the `world` database; restart worldserver. Run 030's rollback on `hotfixes` too.
DELETE FROM creature_queststarter WHERE quest IN (9100301, 9100302);
DELETE FROM creature_questender WHERE quest IN (9100301, 9100302);
DELETE FROM quest_details WHERE ID IN (9100301, 9100302);
DELETE FROM quest_request_items WHERE ID IN (9100301, 9100302);
DELETE FROM quest_offer_reward WHERE ID IN (9100301, 9100302);
DELETE FROM quest_template_addon WHERE ID IN (9100301, 9100302);
DELETE FROM quest_template WHERE ID IN (9100301, 9100302);
