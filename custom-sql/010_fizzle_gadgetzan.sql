-- Leaves Fizzle Everhand with a single spawn in Gadgetzan. Apply to the `world` database.
-- Takes effect after a worldserver restart.
DELETE FROM creature WHERE guid = 26300004;
UPDATE creature SET map = 1, zoneId = 0, areaId = 0, position_x = -7158.59, position_y = -3799.24, position_z = 9.38741, orientation = 3.86792
WHERE guid = 26300003;
