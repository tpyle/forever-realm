-- Durga Lightsworn: new Orgrimmar position and a random male orc appearance. Apply to the `world` database.
UPDATE creature SET map = 1, position_x = 1976.03, position_y = -4796.09, position_z = 55.7926, orientation = 0.482373 WHERE guid = 26300002;
UPDATE creature_template_model SET CreatureDisplayID = 14972 WHERE CreatureID = 8103002 AND Idx = 0;
