-- Give every new character 4 of bag 277845. Apply to the `world` database.
-- Race 0 and class 0 mean all races and classes. Affects new characters only.
DELETE FROM playercreateinfo_item WHERE race = 0 AND class = 0 AND itemid = 277845;
INSERT INTO playercreateinfo_item (race, class, itemid, amount) VALUES (0, 0, 277845, 4);
