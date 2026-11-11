-- Client QuestV2 row for the druid quest in 034 (completed-quest bit 72952). Apply to the `hotfixes` database;
-- restart worldserver.
DELETE FROM quest_v2 WHERE ID = 9100303;
INSERT INTO quest_v2 (ID, UniqueBitFlag, UiQuestDetailsTheme, VerifiedBuild) VALUES (9100303, 72952, 0, 70790);

DELETE FROM hotfix_data WHERE Id = 81000937;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000937, 81000937, 986198281, 9100303, 1, 70790);
