-- Removes the hotfix. Clients that already received it may keep it until their Cache folder is deleted.
DELETE FROM hotfix_data WHERE Id = 81000200;
DELETE FROM char_base_info WHERE ID = 922;
