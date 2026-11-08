-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100321 AND 9100324;
DELETE FROM hotfix_data WHERE Id BETWEEN 2000955 AND 2000958;
