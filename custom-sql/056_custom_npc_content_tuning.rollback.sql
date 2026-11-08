-- Apply to the `world` database; restart worldserver. Restores the ContentTuning each NPC was copied with.
UPDATE creature_template_difficulty SET ContentTuningID = 70   WHERE Entry = 8103001 AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 866  WHERE Entry IN (8103002, 8103003) AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 864  WHERE Entry IN (8103007, 8103008, 8103010) AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 378  WHERE Entry IN (8103004, 8103005, 8103006, 8103009, 8103011, 8103012, 8103013,
    8103015, 8103019, 8103020, 8103026) AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 73   WHERE Entry IN (8103014, 8103016, 8103017, 8103021, 8103024, 8103025, 8103027,
    8103029) AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 72   WHERE Entry = 8103022 AND DifficultyID = 0;
UPDATE creature_template_difficulty SET ContentTuningID = 1477 WHERE Entry IN (8103018, 8103023, 8103028) AND DifficultyID = 0;
