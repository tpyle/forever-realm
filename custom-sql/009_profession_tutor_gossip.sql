-- Gives Fizzle Everhand a gossip menu. The server hides an NPC's gossip flag from players when
-- the NPC has no menu in the database, even if a script supplies one, which made him unclickable.
-- Apply to the `world` database. Takes effect after a worldserver restart.
DELETE FROM creature_template_gossip WHERE CreatureID = 8103003;
DELETE FROM gossip_menu WHERE MenuID = 8103003;

INSERT INTO gossip_menu (MenuID, TextID, VerifiedBuild) VALUES (8103003, 68, 0);
INSERT INTO creature_template_gossip (CreatureID, MenuID, VerifiedBuild) VALUES (8103003, 8103003, 0);
