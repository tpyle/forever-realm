-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM skill_race_class_info WHERE ID = 2616;
DELETE FROM hotfix_data WHERE Id = 2001480;
