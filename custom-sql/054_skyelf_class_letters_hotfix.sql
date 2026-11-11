-- Client QuestV2 rows for the quests in 053 (completed-quest bits 72970-72973). Apply to the `hotfixes` database;
-- restart worldserver.
DELETE FROM quest_v2 WHERE ID BETWEEN 9100321 AND 9100324;
INSERT INTO quest_v2 (ID, UniqueBitFlag, UiQuestDetailsTheme, VerifiedBuild) VALUES
  (9100321, 72970, 0, 70790),
  (9100322, 72971, 0, 70790),
  (9100323, 72972, 0, 70790),
  (9100324, 72973, 0, 70790);

DELETE FROM hotfix_data WHERE Id BETWEEN 81000955 AND 81000958;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES
  (81000955, 81000955, 986198281, 9100321, 1, 70790),
  (81000956, 81000956, 986198281, 9100322, 1, 70790),
  (81000957, 81000957, 986198281, 9100323, 1, 70790),
  (81000958, 81000958, 986198281, 9100324, 1, 70790);
