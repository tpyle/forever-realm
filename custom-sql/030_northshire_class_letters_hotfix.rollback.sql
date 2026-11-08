-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID IN (9100301, 9100302);
DELETE FROM hotfix_data WHERE Id IN (2000935, 2000936);
