-- Apply to the `hotfixes` database; restart worldserver.
DELETE FROM skill_line_ability WHERE ID = 60021;
DELETE FROM hotfix_data WHERE Id = 2001481;
