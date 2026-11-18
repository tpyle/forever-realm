-- Apply to the `world` database; `.reload conditions` (or restart worldserver).
DELETE FROM conditions WHERE SourceTypeOrReferenceId = 19 AND SourceEntry IN (1641, 1645) AND ConditionTypeOrReference IN (2, 47)
    AND ConditionValue1 IN (1642, 1646, 6775, 6916);
