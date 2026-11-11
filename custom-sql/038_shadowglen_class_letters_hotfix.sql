-- Client QuestV2 rows for the quests in 037 (completed-quest bits 72953-72956). Apply to the `hotfixes` database;
-- restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100304 AND 9100307;
INSERT INTO quest_v2 (ID, UniqueBitFlag, UiQuestDetailsTheme, VerifiedBuild) VALUES
  (9100304, 72953, 0, 70790),
  (9100305, 72954, 0, 70790),
  (9100306, 72955, 0, 70790),
  (9100307, 72956, 0, 70790);

DELETE FROM hotfix_data WHERE Id BETWEEN 81000938 AND 81000941;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000938, 81000938, 986198281, 9100304, 1, 70790),
  (81000939, 81000939, 986198281, 9100305, 1, 70790),
  (81000940, 81000940, 986198281, 9100306, 1, 70790),
  (81000941, 81000941, 986198281, 9100307, 1, 70790);
