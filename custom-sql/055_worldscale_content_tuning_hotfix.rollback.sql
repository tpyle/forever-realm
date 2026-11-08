-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM content_tuning WHERE ID BETWEEN 8100001 AND 8100059;
DELETE FROM hotfix_data WHERE Id BETWEEN 2000959 AND 2001017;
