-- Profession caps back to the rank the character has learned (Apprentice 75, Journeyman 150, Expert 225, Artisan 300).
-- A core bug (Player::_LoadSkills, fixed in the core commit "Classic 1.60: profession caps stay at the learned rank at login")
-- raised every profession to Artisan's 300 at login: the Classic child lines (2937-2948) carry ParentTierIndex 4.
-- The cap is 75 x the highest rank spell known (SPELL_EFFECT_SKILL step from SpellEffect.db2); a skill above its cap is
-- lowered to it. The child lines take their profession's values. Rerunnable.
-- Apply to the `characters` database with worldserver stopped (online players would save their old values over it).
DROP TEMPORARY TABLE IF EXISTS tmp_rank_spell;
CREATE TEMPORARY TABLE tmp_rank_spell (spell INT UNSIGNED PRIMARY KEY, skill SMALLINT UNSIGNED, step TINYINT UNSIGNED);
INSERT INTO tmp_rank_spell (spell, skill, step) VALUES
(2018,164,1),
(2108,165,1),
(2259,171,1),
(2366,182,1),
(2368,182,2),
(2550,185,1),
(2575,186,1),
(2576,186,2),
(3100,164,2),
(3101,171,2),
(3102,185,2),
(3104,165,2),
(3273,129,1),
(3274,129,2),
(3413,185,3),
(3464,171,3),
(3538,164,3),
(3564,186,3),
(3570,182,3),
(3811,165,3),
(3908,197,1),
(3909,197,2),
(3910,197,3),
(4036,202,1),
(4037,202,2),
(4038,202,3),
(7411,333,1),
(7412,333,2),
(7413,333,3),
(7620,356,1),
(7731,356,2),
(7732,356,3),
(7924,129,3),
(8613,393,1),
(8617,393,2),
(8618,393,3),
(9785,164,4),
(10248,186,4),
(10662,165,4),
(10768,393,4),
(10846,129,4),
(11611,171,4),
(11993,182,4),
(12180,197,4),
(12656,202,4),
(13920,333,4),
(18248,356,4),
(18260,185,4),
(1235230,186,1),
(1235236,182,1),
(1235244,202,1);

DROP TEMPORARY TABLE IF EXISTS tmp_child_line;
CREATE TEMPORARY TABLE tmp_child_line (child SMALLINT UNSIGNED PRIMARY KEY, parent SMALLINT UNSIGNED);
INSERT INTO tmp_child_line (child, parent) VALUES
(2937,171),(2938,164),(2939,185),(2940,333),(2941,202),(2942,129),(2943,356),(2944,182),(2945,165),(2946,186),(2947,393),(2948,197);

DROP TEMPORARY TABLE IF EXISTS tmp_cap;
CREATE TEMPORARY TABLE tmp_cap (guid BIGINT UNSIGNED, skill SMALLINT UNSIGNED, cap SMALLINT UNSIGNED, PRIMARY KEY (guid, skill))
SELECT s.guid, r.skill, MAX(r.step) * 75 AS cap
FROM character_spell s JOIN tmp_rank_spell r ON r.spell = s.spell
GROUP BY s.guid, r.skill;

UPDATE character_skills cs JOIN tmp_cap c ON c.guid = cs.guid AND c.skill = cs.skill
SET cs.max = c.cap, cs.value = LEAST(cs.value, c.cap)
WHERE cs.max > c.cap;

UPDATE character_skills cs
JOIN tmp_child_line l ON l.child = cs.skill
JOIN character_skills p ON p.guid = cs.guid AND p.skill = l.parent
SET cs.max = p.max, cs.value = p.value
WHERE cs.max <> p.max OR cs.value <> p.value;

DROP TEMPORARY TABLE tmp_rank_spell;
DROP TEMPORARY TABLE tmp_child_line;
DROP TEMPORARY TABLE tmp_cap;
