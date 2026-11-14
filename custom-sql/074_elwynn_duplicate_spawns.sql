-- Upstream's 2026_11_13_52_world_forever_elwynn_hunter_and_camping_npcs.sql (merge for client 70938) spawns four Elwynn NPCs it
-- found missing (Tordrin Sternblade 248415, Josephine Carson 251507, Isaac Chan 258930, Sam Sarsaparilla 263399) at guids
-- 46100000-46100003, positions worked out from live map points. Our world already had each of them from live sniff data
-- (guids 21200082, 21200132, 21200188, 21200312, VerifiedBuild 70170), so each stood twice in the same spot. Keep the sniffed
-- spawns, delete upstream's. Their templates, trainer lists and quest links stay as upstream wrote them.
-- Apply to the `world` database; restart worldserver (or .npc delete them in game). Safe to run more than once (re-run after
-- merges by tools/rerun_custom_sql.sh, since upstream's file re-inserts them).
DELETE FROM creature WHERE guid BETWEEN 46100000 AND 46100003
  AND id IN (248415, 251507, 258930, 263399)
  AND EXISTS (SELECT 1 FROM (SELECT id FROM creature WHERE guid IN (21200082, 21200132, 21200188, 21200312)) sniffed WHERE sniffed.id = creature.id);
