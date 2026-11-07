-- Korgath the Redeemed: new position and a random male orc appearance. Apply to the `world` database.
UPDATE creature SET map = 1, position_x = -625.727, position_y = -4206.51, position_z = 38.1343, orientation = 6.03534 WHERE guid = 26300001;
UPDATE creature_template_model SET CreatureDisplayID = 8352 WHERE CreatureID = 8103001 AND Idx = 0;
