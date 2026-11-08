-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100304 AND 9100307;
DELETE FROM hotfix_data WHERE Id BETWEEN 2000938 AND 2000941;
