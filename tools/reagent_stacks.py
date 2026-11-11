#!/usr/bin/env python3
"""Writes custom-sql/059_reagent_stacks_999.sql (and its rollback): Trade Goods stack to 999.

Every item of class 7 (Trade Goods) that stacks (Stackable above 1) but to less than 999 gets Stackable 999. Single
items (rods, tools, clams, supply crates) and the few that already stack to 1000+ are left alone.

The client takes an item's stack size from ItemSparse, so the change is a hotfix row per item: a full record. Items with a
hotfix row already only have Stackable changed; for the rest the record is read from the client's ItemSparse.db2
(tools/db2read.py, field layout from the core's DB2Metadata.h, column order from HotfixDatabase.cpp). Rerun after a
client update changes ItemSparse, then reapply (rollback first).

    tools/reagent_stacks.py
"""
import os
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
CORE = ROOT / "TrinityCore" / "src" / "server"
DBC = ROOT / "server" / "data" / "dbc" / "enUS"
OUT = ROOT / "custom-sql" / "059_reagent_stacks_999"
STACK = 999
TRADE_GOODS = 7
ITEM_SPARSE_HASH = 2442913102
VERIFIED_BUILD = 70790
FIRST_HOTFIX_ID = 81001018


def meta(name):
    source = (CORE / "game" / "DataStores" / "DB2Metadata.h").read_text()
    block = re.search(r"struct " + name + r"Meta\s*\{.*?Fields\[\d+\] =\s*\{(.*?)\};", source, re.S).group(1)
    types = {"INT": "int", "FLOAT": "float", "STRING": "string", "STRING_NOT_LOCALIZED": "string", "SHORT": "short",
             "BYTE": "byte"}
    return [(types[t], int(a), s == "true")
            for t, a, s in re.findall(r"FT_(\w+),\s*\.ArraySize =\s*(\d+), \.IsSigned =\s*(\w+)", block)]


def columns(statement):
    source = (CORE / "database" / "Database" / "Implementation" / "HotfixDatabase.cpp").read_text()
    select = re.search(r"PrepareStatement\(" + statement + r', "SELECT (.*?) FROM', source, re.S).group(1)
    return [c.strip() for c in re.sub(r'"\s*"', "", select).split(",")]


def flat(values):
    out = []
    for value in values:
        out += value if isinstance(value, list) else [value]
    return out


def mysql(query):
    env = {**os.environ, "MYSQL_PWD": (ROOT / ".db_pass").read_text().strip()}
    result = subprocess.run(["mysql", "-h127.0.0.1", "-utrinity", "-N", "--batch", "hotfixes", "-e", query],
                            capture_output=True, text=True, env=env, check=True)
    return [line.split("\t") for line in result.stdout.splitlines()]


def sql_value(value):
    if isinstance(value, str):
        return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"
    if isinstance(value, float):
        return repr(value)
    return str(value)


def main():
    sparse_columns = columns("HOTFIX_SEL_ITEM_SPARSE")
    stack_index = sparse_columns.index("Stackable")

    items, _ = db2read.read(DBC / "Item.db2", meta("Item"))
    item_class = {item_id: values[0] for item_id, values in items.items()}
    for item_id, class_id in mysql("SELECT ID, ClassID FROM item"):
        item_class[int(item_id)] = int(class_id)

    sparse, _ = db2read.read(DBC / "ItemSparse.db2", meta("ItemSparse"))
    records = {item_id: [item_id] + flat(values) for item_id, values in sparse.items()}
    if any(len(r) != len(sparse_columns) for r in records.values()):
        sys.exit("ItemSparse.db2 does not match the item_sparse columns")

    hotfixed = {int(item_id): (int(stack), build)
                for item_id, stack, build in mysql("SELECT ID, Stackable, VerifiedBuild FROM item_sparse")}

    def current_stack(item_id):
        return hotfixed[item_id][0] if item_id in hotfixed else records[item_id][stack_index]

    targets = sorted(i for i in set(records) | set(hotfixed)
                     if item_class.get(i) == TRADE_GOODS and 1 < current_stack(i) < STACK)
    inserted = [i for i in targets if i not in hotfixed]
    updated = [i for i in targets if i in hotfixed]

    lines = [
        f"-- Trade Goods stack to {STACK} (written by tools/reagent_stacks.py: {len(targets)} items, {len(inserted)} new",
        f"-- item_sparse rows from the client's ItemSparse.db2, {len(updated)} existing rows changed). Every item of class 7",
        "-- that stacks to between 2 and 998; single items (rods, tools, clams, crates) and 1000+ stacks are unchanged.",
        "-- Apply to the `hotfixes` database; restart worldserver. Clients download the hotfixes at login.",
    ]
    for item_id in updated:
        lines.append(f"UPDATE item_sparse SET Stackable = {STACK} WHERE ID = {item_id};")
    column_list = ", ".join(f"`{c}`" for c in sparse_columns + ["VerifiedBuild"])
    for start in range(0, len(inserted), 50):
        lines.append(f"INSERT INTO item_sparse ({column_list}) VALUES")
        chunk = inserted[start:start + 50]
        for n, item_id in enumerate(chunk):
            record = list(records[item_id])
            record[stack_index] = STACK
            values = ", ".join(sql_value(v) for v in record + [VERIFIED_BUILD])
            lines.append(f"({values})" + ("," if n + 1 < len(chunk) else ";"))
    lines.append("INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES")
    hotfix_ids = range(FIRST_HOTFIX_ID, FIRST_HOTFIX_ID + len(targets))
    lines += [f"({h}, {h}, {ITEM_SPARSE_HASH}, {item_id}, 1, {VERIFIED_BUILD})" + ("," if n + 1 < len(targets) else ";")
              for n, (h, item_id) in enumerate(zip(hotfix_ids, targets))]
    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")

    rollback = ["-- Apply to the `hotfixes` database; restart worldserver."]
    for item_id in updated:
        rollback.append(f"UPDATE item_sparse SET Stackable = {hotfixed[item_id][0]} WHERE ID = {item_id};")
    for start in range(0, len(inserted), 200):
        ids = ", ".join(map(str, inserted[start:start + 200]))
        rollback.append(f"DELETE FROM item_sparse WHERE VerifiedBuild = {VERIFIED_BUILD} AND ID IN ({ids});")
    rollback.append(f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")
    print(f"{len(targets)} items ({len(inserted)} inserted, {len(updated)} updated), hotfix_data "
          f"{hotfix_ids.start}-{hotfix_ids.stop - 1}")


if __name__ == "__main__":
    main()
