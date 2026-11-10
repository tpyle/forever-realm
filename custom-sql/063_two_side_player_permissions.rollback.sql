-- Apply to the `auth` database; `reload rbac` on the world console (or restart worldserver).
DELETE FROM rbac_linked_permissions WHERE id = 195 AND linkedId BETWEEN 25 AND 29;
