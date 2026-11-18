-- The Tome of Divinity, the first quest of the paladin's level 12 chain (1641 human from Duthorian Rall, 1645 dwarf): it is
-- repeatable so a lost tome can be had again, and nothing hid it, so Duthorian Rall offered it for ever after the chain was
-- done. Now only while the quest the tome starts (1642, 1646) is not yet complete or rewarded, and no tome is carried or banked.
-- Apply to the `world` database; `.reload conditions` (or restart worldserver).
DELETE FROM conditions WHERE SourceTypeOrReferenceId = 19 AND SourceEntry IN (1641, 1645) AND ConditionTypeOrReference IN (2, 47)
    AND ConditionValue1 IN (1642, 1646, 6775, 6916);
INSERT INTO conditions (SourceTypeOrReferenceId, SourceGroup, SourceEntry, SourceId, ElseGroup, ConditionTypeOrReference, ConditionTarget,
    ConditionValue1, ConditionValue2, ConditionValue3, ConditionStringValue1, NegativeCondition, ErrorType, ErrorTextId, ScriptName, Comment) VALUES
(19, 0, 1641, 0, 0, 47, 0, 1642, 9, 0, '', 0, 0, 0, '', 'Tome of Divinity 1641: 1642 not complete or rewarded'),
(19, 0, 1641, 0, 0,  2, 0, 6775, 1, 1, '', 1, 0, 0, '', 'Tome of Divinity 1641: no Tome of Divinity in bags or bank'),
(19, 0, 1645, 0, 0, 47, 0, 1646, 9, 0, '', 0, 0, 0, '', 'Tome of Divinity 1645: 1646 not complete or rewarded'),
(19, 0, 1645, 0, 0,  2, 0, 6916, 1, 1, '', 1, 0, 0, '', 'Tome of Divinity 1645: no Tome of Divinity in bags or bank');
