-- Removes the orc paladin starting gear. Clients may keep it until their Cache folder is deleted.
DELETE FROM hotfix_data WHERE Id BETWEEN 81000201 AND 81000216;
DELETE FROM character_loadout_item WHERE ID BETWEEN 36905 AND 36918;
DELETE FROM character_loadout WHERE ID IN (3000, 3001);
