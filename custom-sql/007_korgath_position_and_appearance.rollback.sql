-- Restores Korgath's previous position and appearance.
UPDATE creature SET map = 1, position_x = -636.73, position_y = -4228.9, position_z = 38.5605, orientation = 5.72468 WHERE guid = 26300001;
UPDATE creature_template_model SET CreatureDisplayID = 1880 WHERE CreatureID = 8103001 AND Idx = 0;
