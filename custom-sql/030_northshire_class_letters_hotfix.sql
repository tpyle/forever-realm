-- Client QuestV2 rows for the quests in 029 (the client tracks completed quests by UniqueBitFlag; 72701-72949 are the
-- talent markers in 025). Apply to the `hotfixes` database; restart worldserver.
DELETE FROM quest_v2 WHERE ID IN (9100301, 9100302);
INSERT INTO quest_v2 (ID, UniqueBitFlag, UiQuestDetailsTheme, VerifiedBuild) VALUES
  (9100301, 72950, 0, 70790),
  (9100302, 72951, 0, 70790);

DELETE FROM hotfix_data WHERE Id IN (81000935, 81000936);
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000935, 81000935, 986198281, 9100301, 1, 70790),
  (81000936, 81000936, 986198281, 9100302, 1, 70790);
