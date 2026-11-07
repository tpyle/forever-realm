-- Removes the orc paladin combination. Delete any orc paladin characters first.
DELETE FROM playercreateinfo_action WHERE race = 2 AND class = 2;
DELETE FROM playercreateinfo WHERE race = 2 AND class = 2;
DELETE FROM class_expansion_requirement WHERE RaceID = 2 AND ClassID = 2;
