-- Cross-faction play for ordinary accounts (with the AllowTwoSide settings in tools/apply_config.py).
-- Say/yell understood across factions (25), channels (26), mail (27), the who list (28) and friends (29) are RBAC
-- permissions, which stock TrinityCore gives only to moderators (194); this links them to the player role (195) too.
-- Whispers between factions use 25 as well.
-- Apply to the `auth` database; `reload rbac` on the world console (or restart worldserver).
DELETE FROM rbac_linked_permissions WHERE id = 195 AND linkedId BETWEEN 25 AND 29;
INSERT INTO rbac_linked_permissions (id, linkedId) VALUES (195, 25), (195, 26), (195, 27), (195, 28), (195, 29);
