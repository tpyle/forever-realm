-- Restores Durga's original position and Grezz Ragefist's appearance.
UPDATE creature SET position_x = 1982.79, position_y = -4798.89, position_z = 55.8813, orientation = 1.32645 WHERE guid = 26300002;
UPDATE creature_template_model SET CreatureDisplayID = 1374 WHERE CreatureID = 8103002 AND Idx = 0;
