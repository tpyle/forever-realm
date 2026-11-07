-- Puts Fizzle Everhand back in Orgrimmar and Northshire.
UPDATE creature SET map = 1, zoneId = 0, areaId = 0, position_x = 1978.52, position_y = -4797.59, position_z = 55.7926, orientation = 0.482373
WHERE guid = 26300003;

DELETE FROM creature WHERE guid = 26300004;
CREATE TEMPORARY TABLE tmp_clone SELECT * FROM creature WHERE guid = 20079967;
UPDATE tmp_clone SET guid = 26300004, id = 8103003, equipment_id = 0, position_x = -8911.70, position_y = -214.52, ScriptName = '';
INSERT INTO creature SELECT * FROM tmp_clone;
DROP TEMPORARY TABLE tmp_clone;
