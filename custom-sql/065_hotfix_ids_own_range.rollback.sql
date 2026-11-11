-- Rollback of 065: our hotfix_data push ids back to 2000200-2001481 (only if upstream's rows do not hold them by then).
-- Apply to the `hotfixes` database with worldserver stopped; restart worldserver.
UPDATE hotfix_data SET Id = Id - 81000000 + 2000000, UniqueId = UniqueId - 81000000 + 2000000
WHERE Id BETWEEN 81000200 AND 81001481 AND UniqueId = Id;
