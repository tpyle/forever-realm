#!/usr/bin/env python3
"""Writes custom-sql/069_quest_poi_explore.sql (and its rollback): map areas for the explore step of exploration quests.

These quests (The Jasperlode Mine and others) complete by walking into an area trigger. Upstream gave them their
objective line (world 2026_10_25_02), but their quest_poi data, from WotLK (build 12340), has only the turn-in point, so
the map showed nothing until the area was explored. Live data (Kobold Camp Cleanup, 7) has a blob per objective
(ObjectiveIndex = the objective's StorageIndex, its QuestObjectiveID, Flags 1) beside the turn-in.

For each quest: one blob on the map of its existing POI, the convex hull of a circle around each of its triggers
(areatrigger_involvedrelation; position and radius from AreaTrigger.db2), put on the next free Idx1.

    tools/quest_poi_explore.py 76 62 ...      (the quests to cover; none: every quest in QUESTS)
"""
import math
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, meta  # noqa: E402

OUT = ROOT / "custom-sql" / "070_quest_poi_explore"
# the vanilla exploration quests whose objective is an area trigger and that have no objective POI (069 gives most their live
# objective; 273 has none any more, and 984's triggers are not in the client)
QUESTS = [62, 76, 201, 578, 944, 1149, 1265, 1448, 1658, 1699, 2240, 2989, 4811, 4842, 6025, 8286]
SIDES = 8
MIN_RADIUS = 20.0


def query(sql, db="world"):
    env = dict(os.environ, MYSQL_PWD=(ROOT / ".db_pass").read_text().strip())
    out = subprocess.run(["mysql", "-h127.0.0.1", "-utrinity", "-N", "-B", db, "-e", sql],
                         env=env, check=True, capture_output=True, text=True).stdout
    return [line.split("\t") for line in out.splitlines() if line]


def hull(points):
    points = sorted(set(points))
    if len(points) <= 2:
        return points

    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower, upper = [], []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def main():
    quests = [int(q) for q in sys.argv[1:]] or QUESTS
    # trigger id -> (x, y, z, map, radius): the client's AreaTrigger.db2, then the hotfix rows (some are only there)
    client, _ = db2read.read(DBC / "AreaTrigger.db2", meta("AreaTrigger"))
    triggers = {i: (*v[0], v[2], v[6]) for i, v in client.items()}
    triggers.update({int(r[0]): (float(r[1]), float(r[2]), float(r[3]), int(r[4]), float(r[5])) for r in
                     query("SELECT ID, PosX, PosY, PosZ, ContinentID, Radius FROM area_trigger", "hotfixes")})
    skipped = []
    lines = [
        "-- Map areas for the explore step of exploration quests (written by tools/quest_poi_explore.py). Their quest_poi had",
        "-- only the turn-in point, so the map showed nothing until the area was explored. One blob per quest around its",
        "-- area triggers, as the objective's POI (as live data has for other quests).",
        "-- Apply to the `world` database; `reload quest_poi` (no restart). Clients see it after a relog.",
    ]
    rollback = ["-- Apply to the `world` database; `reload quest_poi`."]
    for quest in quests:
        objective = query(f"SELECT ID, StorageIndex, ObjectID FROM quest_objectives WHERE QuestID={quest} AND Type=10")
        if len(objective) != 1:
            skipped.append(f"quest {quest}: area trigger objectives {objective}")
            continue
        objective_id, storage, object_id = map(int, objective[0])
        # our own row from an earlier run does not count
        poi = query(f"SELECT MapID, UiMapID, MAX(Idx1) FROM quest_poi WHERE QuestID={quest} AND QuestObjectiveID<>{objective_id} "
                    "GROUP BY MapID, UiMapID")
        # the objective's own trigger when it names one (any of the quest's triggers credits an ObjectID -1 objective)
        ids = [object_id] if object_id > 0 else \
            [int(r[0]) for r in query(f"SELECT id FROM areatrigger_involvedrelation WHERE quest={quest}")]
        if len(poi) != 1 or not ids or any(i not in triggers for i in ids):
            skipped.append(f"quest {quest}: POI maps {poi}, triggers {ids}")
            continue
        map_id, ui_map, last_idx = map(int, poi[0])
        if query(f"SELECT 1 FROM quest_poi WHERE QuestID={quest} AND ObjectiveIndex BETWEEN 0 AND 31 "
                 f"AND QuestObjectiveID<>{objective_id}"):
            sys.exit(f"quest {quest} already has an objective POI")

        corners, z = [], []
        for trigger in ids:
            x, y, tz, map_of, radius = triggers[trigger]
            if map_of != map_id:
                continue
            radius = max(radius, MIN_RADIUS)
            z.append(tz)
            corners += [(round(x + radius * math.cos(2 * math.pi * k / SIDES)),
                         round(y + radius * math.sin(2 * math.pi * k / SIDES))) for k in range(SIDES)]
        if not corners:
            skipped.append(f"quest {quest}: no trigger on map {map_id}")
            continue
        idx = last_idx + 1
        z_avg = round(sum(z) / len(z))
        points = hull(corners)

        lines.append(f"-- quest {quest}: triggers {', '.join(map(str, ids))}")
        delete = [f"DELETE FROM quest_poi WHERE QuestID={quest} AND QuestObjectiveID={objective_id};",
                  f"DELETE FROM quest_poi_points WHERE QuestID={quest} AND Idx1={idx};"]
        lines += delete
        lines.append("INSERT INTO quest_poi (QuestID, BlobIndex, Idx1, ObjectiveIndex, QuestObjectiveID, QuestObjectID, MapID, "
                     f"UiMapID, Priority, Flags, VerifiedBuild) VALUES ({quest}, 0, {idx}, {storage}, {objective_id}, 0, "
                     f"{map_id}, {ui_map}, 0, 1, 0);")
        lines.append("INSERT INTO quest_poi_points (QuestID, Idx1, Idx2, X, Y, Z, VerifiedBuild) VALUES\n" + ",\n".join(
            f"  ({quest}, {idx}, {n}, {x}, {y}, {z_avg}, 0)" for n, (x, y) in enumerate(points)) + ";")
        rollback += delete
        print(f"quest {quest}: Idx1 {idx}, objective {objective_id}, {len(points)} points around triggers {ids}")

    for line in skipped:
        print("skipped", line)
    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")


if __name__ == "__main__":
    main()
