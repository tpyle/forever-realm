-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100308 AND 9100310;
DELETE FROM hotfix_data WHERE Id BETWEEN 2000942 AND 2000944;
