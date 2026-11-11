-- Test: tell the client orc paladin is valid. Apply to the `hotfixes` database.
-- 812099832 is the CharBaseInfo table hash; record 922 is one past the client's highest ID.
DELETE FROM char_base_info WHERE ID = 922;
INSERT INTO char_base_info (ID, RaceID, ClassID, OtherFactionRaceID, VerifiedBuild) VALUES (922, 2, 2, 0, 70790);
DELETE FROM hotfix_data WHERE Id = 81000200;
INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES (81000200, 81000200, 812099832, 922, 1, 70790);
