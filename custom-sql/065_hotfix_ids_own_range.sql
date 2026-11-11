-- Our hotfix_data push ids move from 2000200-2001481 to 81000200-81001481 (n -> n - 2000000 + 81000000).
-- Upstream (advocaite forever 0.1.34) now uses push ids 2000001-2054257, and both sides delete their rows by id range,
-- so each wiped the other's hotfixes. Files 002-062 already use the new ids; this moves the rows already in the database.
-- Only our rows (UniqueId = Id) move; upstream's 2000001-2000199 stay. Rerunnable.
-- Apply to the `hotfixes` database with worldserver stopped, before upstream's hotfix SQL; restart worldserver.
UPDATE IGNORE hotfix_data SET Id = Id - 2000000 + 81000000, UniqueId = UniqueId - 2000000 + 81000000
WHERE Id BETWEEN 2000200 AND 2001481 AND UniqueId = Id;
-- what is left collided with a row already at its new id (002-062 run again before this): the old copy goes
DELETE FROM hotfix_data WHERE Id BETWEEN 2000200 AND 2001481 AND UniqueId = Id;
