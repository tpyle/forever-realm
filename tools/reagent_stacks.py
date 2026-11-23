#!/usr/bin/env python3
"""Writes custom-sql/059_reagent_stacks_999.sql (and its rollback): Trade Goods stack to 999.

Every item of class 7 (Trade Goods) that stacks (Stackable above 1) but to less than 999 gets Stackable 999. Single
items (rods, tools, clams, supply crates) and the few that already stack to 1000+ are left alone.

The client takes an item's stack size from ItemSparse, so the change is a hotfix row per item: a full record. Items with a
hotfix row already only have Stackable changed; for the rest the record is read from the client's ItemSparse.db2
(tools/db2read.py, field layout from the core's DB2Metadata.h, column order from HotfixDatabase.cpp). The items are chosen
by their stock stack (ItemSparse.db2), so the output does not depend on whether 059 is applied. Rerun after a client
update changes ItemSparse, then apply the new 059 (no rollback needed: it is safe to run again).

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
FIRST_COUNT = 462
# Trade Goods that upstream added hotfix rows for after 059 was first written (0.1.39); ids above the other files' (078)
LATER_HOTFIX_IDS = {2665: 81001896, 6987: 81001897}


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

    # Upstream hotfix rows (some are full live records with stock stack sizes, applied after 059: Steel Bar and ten more
    # in 2026_11_06_40_hotfixes_forever_live_pushes_70790.sql). Items without an ItemSparse.db2 record are upstream rows
    # only; their stock stacks are kept here, as the database holds 999 once 059 is in.
    hotfixed = {int(item_id): int(stack) for item_id, stack in mysql("SELECT ID, Stackable FROM item_sparse")}
    no_record_stock = {215127: 10, 215168: 10}

    def stock_stack(item_id):
        if item_id in records:
            return records[item_id][stack_index]
        return no_record_stock.get(item_id, hotfixed.get(item_id))

    targets = sorted(i for i in set(records) | set(hotfixed)
                     if item_class.get(i) == TRADE_GOODS and 1 < stock_stack(i) < STACK)
    missing = [i for i in targets if i not in records and i in hotfixed and hotfixed[i] == STACK
               and i not in no_record_stock]
    if missing:
        sys.exit(f"no stock stack known for {missing}")
    from_db2 = [i for i in targets if i in records]

    # Safe to run again (tools/rerun_custom_sql.sh does after an upstream merge): a row an upstream file already has is
    # kept (INSERT IGNORE) and only its Stackable is changed.
    lines = [
        f"-- Trade Goods stack to {STACK} (written by tools/reagent_stacks.py: {len(targets)} items). Every item of class 7 that",
        "-- stacks to between 2 and 998; single items (rods, tools, clams, crates) and 1000+ stacks are unchanged. Items without",
        f"-- a hotfix row get their record from the client's ItemSparse.db2 ({len(from_db2)} records, kept where upstream has a row);",
        "-- then every one gets Stackable 999. Safe to run again: tools/rerun_custom_sql.sh does after an upstream merge.",
        "-- Apply to the `hotfixes` database; restart worldserver. Clients download the hotfixes at login.",
    ]
    column_list = ", ".join(f"`{c}`" for c in sparse_columns + ["VerifiedBuild"])
    for start in range(0, len(from_db2), 50):
        lines.append(f"INSERT IGNORE INTO item_sparse ({column_list}) VALUES")
        chunk = from_db2[start:start + 50]
        for n, item_id in enumerate(chunk):
            values = ", ".join(sql_value(v) for v in records[item_id] + [VERIFIED_BUILD])
            lines.append(f"({values})" + ("," if n + 1 < len(chunk) else ";"))
    for start in range(0, len(targets), 200):
        ids = ", ".join(map(str, targets[start:start + 200]))
        lines.append(f"UPDATE item_sparse SET Stackable = {STACK} WHERE ID IN ({ids});")
    # The first 462 items keep the push ids 059 gave them; items added later take ids from LATER_HOTFIX_IDS. A record that an
    # upstream push also lists is sent under both ids, which does no harm.
    first = [i for i in targets if i not in LATER_HOTFIX_IDS]
    if len(first) != FIRST_COUNT:
        sys.exit(f"{len(first)} items outside LATER_HOTFIX_IDS (expected {FIRST_COUNT}): give the new ones ids there")
    hotfix_ids = range(FIRST_HOTFIX_ID, FIRST_HOTFIX_ID + FIRST_COUNT)
    pushes = sorted(list(zip(hotfix_ids, first)) + [(h, i) for i, h in LATER_HOTFIX_IDS.items() if i in targets])
    lines.append("INSERT IGNORE INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES")
    lines += [f"({h}, {h}, {ITEM_SPARSE_HASH}, {item_id}, 1, {VERIFIED_BUILD})" + ("," if n + 1 < len(pushes) else ";")
              for n, (h, item_id) in enumerate(pushes)]
    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")

    # Puts the stock stack sizes back. The rows stay: they then equal the client's record (or upstream's row), and upstream
    # files may own some of them by now.
    rollback = ["-- Apply to the `hotfixes` database; restart worldserver. Sets the stock stack sizes back; the item_sparse rows",
                "-- stay (with stock values they equal the client's record or upstream's row)."]
    by_stack = {}
    for item_id in targets:
        by_stack.setdefault(stock_stack(item_id), []).append(item_id)
    for stack, ids in sorted(by_stack.items()):
        for start in range(0, len(ids), 200):
            rollback.append(f"UPDATE item_sparse SET Stackable = {stack} WHERE ID IN ({', '.join(map(str, ids[start:start + 200]))});")
    rollback.append(f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};")
    rollback.append(f"DELETE FROM hotfix_data WHERE Id IN ({', '.join(str(h) for h in sorted(LATER_HOTFIX_IDS.values()))});")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")
    print(f"{len(targets)} items ({len(from_db2)} records from ItemSparse.db2), hotfix_data "
          f"{hotfix_ids.start}-{hotfix_ids.stop - 1} and {sorted(LATER_HOTFIX_IDS.values())}")


if __name__ == "__main__":
    main()
