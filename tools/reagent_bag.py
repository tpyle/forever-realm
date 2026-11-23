#!/usr/bin/env python3
"""Writes custom-sql/080_crafting_reagent_bag_hotfix.sql (and its rollback): a 40 slot bag for every crafting reagent.

A profession bag holds what shares a bit of its own BagFamily (Item.cpp ItemCanGoIntoBag, and the client's bag check).
Cloth, thread, meat, elementals, engineering parts, stone and the like have no family bit at all, so no bag could take
them. This gives every crafting reagent a family bit of its own (REAGENT_FAMILY, used by no item before): every Trade
Goods item (class 7) and every item the client marks as used in a tradeskill (Flags2 0x80000000: Light Feather, Black
Diamond, Deviate Fish, Holiday Spices and so on). Their other bits stay, so herb and mining bags still take what they did.

The bag (BAG_ID, hotfix only) is a copy of Satchel of Cenarius (22252) as an Engineering Bag (container subclass 4, which
no Classic bag uses; the server needs a profession subclass to check families, and subclass 11 reagent bags only go in
the reagent bag slot), 40 slots, BagFamily = REAGENT_FAMILY. The client shows "Engineering Bag" on it: the server has no
ItemSubClass hotfix table to rename the subclass. Created with .additem only (no vendor or recipe).

The reagents' records are whole ItemSparse rows, as in 059: a record no hotfix row has yet comes from the client's
ItemSparse.db2 (INSERT IGNORE: an upstream row is kept), then one UPDATE sets the bit. Push IDs are 82000000 + item ID, so
they do not move when the item set changes. Safe to run again; tools/rerun_custom_sql.sh does after an upstream merge.
The bag's records use BAG_HOTFIX_IDS; give them new ones if the bag's records change (a client keeps a cached record).

    tools/reagent_bag.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, VERIFIED_BUILD, columns, flat, meta, mysql, sql_value  # noqa: E402

OUT = ROOT / "custom-sql" / "080_crafting_reagent_bag_hotfix"
REAGENT_FAMILY = 0x10000000
USED_IN_A_TRADESKILL = 0x80000000   # Flags2 (ITEM_FLAG2_USED_IN_A_TRADESKILL)
TRADE_GOODS = 7
BAG_ID = 8104122
BAG_NAME = "Crafting Reagent Bag"
BAG_DESCRIPTION = "Holds any crafting reagent."
BAG_SLOTS = 40
TEMPLATE_BAG = 22252          # Satchel of Cenarius (32 slot herb bag)
ENGINEERING_CONTAINER = 4
RARE = 3
BAG_HOTFIX_IDS = (81001898, 81001899)   # Item, ItemSparse (above 059's last, 81001897)
REAGENT_HOTFIX_BASE = 82000000
HASH = {"item": 1344507586, "item_sparse": 2442913102}


def main():
    item_cols = columns("HOTFIX_SEL_ITEM")
    sparse_cols = columns("HOTFIX_SEL_ITEM_SPARSE")
    items, _ = db2read.read(DBC / "Item.db2", meta("Item"))
    sparse, _ = db2read.read(DBC / "ItemSparse.db2", meta("ItemSparse"))
    records = {i: [i] + flat(v) for i, v in sparse.items()}
    if any(len(r) != len(sparse_cols) for r in records.values()):
        sys.exit("ItemSparse.db2 does not match the item_sparse columns")
    if BAG_ID in items or BAG_ID in sparse:
        sys.exit(f"{BAG_ID} is already a client item")

    item_class = {i: v[0] for i, v in items.items()}
    for i, c in mysql("SELECT ID, ClassID FROM item"):
        item_class[int(i)] = int(c)
    flags2_at, family_at = sparse_cols.index("Flags2"), sparse_cols.index("BagFamily")
    flags2 = {i: r[flags2_at] & 0xFFFFFFFF for i, r in records.items()}
    hotfixed = set()
    for i, f in mysql("SELECT ID, Flags2 FROM item_sparse"):
        hotfixed.add(int(i))
        flags2[int(i)] = int(f) & 0xFFFFFFFF
    used = 0
    for r in records.values():
        used |= r[family_at] & 0xFFFFFFFF
    if used & REAGENT_FAMILY:
        sys.exit(f"family bit {REAGENT_FAMILY:#x} is already on a client item")

    reagents = sorted(i for i in (set(records) | hotfixed) - {BAG_ID}
                      if item_class.get(i) == TRADE_GOODS or flags2.get(i, 0) & USED_IN_A_TRADESKILL)
    if reagents[-1] > 999999:
        sys.exit(f"item {reagents[-1]} does not fit the push IDs {REAGENT_HOTFIX_BASE} + item ID")
    from_db2 = [i for i in reagents if i in records]
    trade_goods = sum(item_class.get(i) == TRADE_GOODS for i in reagents)

    item = dict(zip(item_cols, [TEMPLATE_BAG] + flat(items[TEMPLATE_BAG])))
    item.update(ID=BAG_ID, SubclassID=ENGINEERING_CONTAINER)
    bag = dict(zip(sparse_cols, records[TEMPLATE_BAG]))
    bag.update(ID=BAG_ID, Display=BAG_NAME, Description=BAG_DESCRIPTION, ContainerSlots=BAG_SLOTS,
               BagFamily=REAGENT_FAMILY, OverallQualityID=RARE, ItemLevel=70, SellPrice=40000, BuyPrice=160000)

    def row(values):
        return "(" + ", ".join(sql_value(v) for v in values + [VERIFIED_BUILD]) + ")"

    def names(cols):
        return ", ".join(f"`{c}`" for c in cols + ["VerifiedBuild"])

    lines = [
        f"-- Crafting Reagent Bag (written by tools/reagent_bag.py): {BAG_ID}, {BAG_SLOTS} slots, holds every crafting reagent.",
        f"-- Every reagent ({len(reagents)} items: {trade_goods} Trade Goods and {len(reagents) - trade_goods} others the client marks as used in a",
        f"-- tradeskill) gets bag family bit {REAGENT_FAMILY:#x}, the bag's only one; their other bits stay. Reagents without a",
        f"-- hotfix row get their record from the client's ItemSparse.db2 (INSERT IGNORE). The bag copies Satchel of Cenarius",
        f"-- ({TEMPLATE_BAG}) as an Engineering Bag (subclass {ENGINEERING_CONTAINER}). No vendor or recipe: .additem {BAG_ID}.",
        "-- Safe to run again. Apply to the `hotfixes` database; restart worldserver. Clients download the hotfixes at login.",
        f"DELETE FROM item WHERE ID = {BAG_ID};",
        f"INSERT INTO item ({names(item_cols)}) VALUES {row(list(item.values()))};",
        f"DELETE FROM item_sparse WHERE ID = {BAG_ID};",
        f"INSERT INTO item_sparse ({names(sparse_cols)}) VALUES {row(list(bag.values()))};",
    ]
    for start in range(0, len(from_db2), 50):
        chunk = from_db2[start:start + 50]
        lines.append(f"INSERT IGNORE INTO item_sparse ({names(sparse_cols)}) VALUES")
        lines += [row(records[i]) + ("," if n + 1 < len(chunk) else ";") for n, i in enumerate(chunk)]
    for start in range(0, len(reagents), 200):
        ids = ", ".join(map(str, reagents[start:start + 200]))
        lines.append(f"UPDATE item_sparse SET BagFamily = BagFamily | {REAGENT_FAMILY} WHERE ID IN ({ids});")
    pushes = [(BAG_HOTFIX_IDS[0], HASH["item"], BAG_ID), (BAG_HOTFIX_IDS[1], HASH["item_sparse"], BAG_ID)]
    pushes += [(REAGENT_HOTFIX_BASE + i, HASH["item_sparse"], i) for i in reagents]
    lines.append("INSERT IGNORE INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES")
    lines += [f"({h}, {h}, {t}, {i}, 1, {VERIFIED_BUILD})" + ("," if n + 1 < len(pushes) else ";")
              for n, (h, t, i) in enumerate(pushes)]
    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")

    rollback = [
        "-- Apply to the `hotfixes` database; restart worldserver. Takes the bit off again; the reagents' item_sparse rows",
        "-- stay (without it they equal the client's record or upstream's row). Bags already made stay in inventories as",
        "-- items the server no longer knows: delete them first (character item_instance rows of item " + str(BAG_ID) + ").",
        f"DELETE FROM item WHERE ID = {BAG_ID};",
        f"DELETE FROM item_sparse WHERE ID = {BAG_ID};",
    ]
    for start in range(0, len(reagents), 200):
        ids = ", ".join(map(str, reagents[start:start + 200]))
        rollback.append(f"UPDATE item_sparse SET BagFamily = BagFamily & ~{REAGENT_FAMILY} WHERE ID IN ({ids});")
    rollback.append(f"DELETE FROM hotfix_data WHERE Id IN {BAG_HOTFIX_IDS};")
    rollback.append(f"DELETE FROM hotfix_data WHERE Id BETWEEN {REAGENT_HOTFIX_BASE} AND {REAGENT_HOTFIX_BASE + 999999};")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")
    print(f"bag {BAG_ID}; {len(reagents)} reagents ({trade_goods} Trade Goods), {len(from_db2)} records from ItemSparse.db2")


if __name__ == "__main__":
    main()
