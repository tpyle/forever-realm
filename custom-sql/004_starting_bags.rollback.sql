-- Stops giving the bags to new characters. Existing characters keep theirs.
DELETE FROM playercreateinfo_item WHERE race = 0 AND class = 0 AND itemid = 277845;
