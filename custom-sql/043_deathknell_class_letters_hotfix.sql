-- Client QuestV2 rows for the quests in 042 (completed-quest bits 72957-72959). Apply to the `hotfixes` database;
-- restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100308 AND 9100310;
INSERT INTO quest_v2 (ID, UniqueBitFlag, UiQuestDetailsTheme, VerifiedBuild) VALUES
  (9100308, 72957, 0, 70790),
  (9100309, 72958, 0, 70790),
  (9100310, 72959, 0, 70790);

DELETE FROM hotfix_data WHERE Id BETWEEN 2000942 AND 2000944;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (2000942, 2000942, 986198281, 9100308, 1, 70790),
  (2000943, 2000943, 986198281, 9100309, 1, 70790),
  (2000944, 2000944, 986198281, 9100310, 1, 70790);
