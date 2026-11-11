-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100316 AND 9100320;
DELETE FROM hotfix_data WHERE Id BETWEEN 81000950 AND 81000954;
