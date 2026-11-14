-- Apply to the `characters` database with worldserver stopped. The old Talent.db2 picks cannot be rebuilt from the
-- node entries: this clears the stance talents (every point comes back).
DELETE FROM character_class_stance_talent;
