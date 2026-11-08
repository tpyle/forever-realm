-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100311 AND 9100315;
DELETE FROM hotfix_data WHERE Id BETWEEN 2000945 AND 2000949;
