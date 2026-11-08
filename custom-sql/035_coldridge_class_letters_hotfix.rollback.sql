-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID = 9100303;
DELETE FROM hotfix_data WHERE Id = 2000937;
