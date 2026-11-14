#!/usr/bin/env python3
"""Writes custom-sql/078_deciphering_scrolls_any_class.sql (and its rollback): the mage's scrolls for Mage Stance holders.

The scrolls a mage reads with Comprehend Scroll (Decipher 1296017; classic_spell_scripts.cpp, ClassicScrollDeciphering) are marked
"Classes: Mage" (ItemSparse.AllowableClass 128), and the client refuses a click on them before the server hears of it, so a
character with Mage Stance (ClassStance.h) could not use them. AllowableClass -1 lets the client send the click; the scrolls still
ask for the deciphering skill (3012), which only mages and Mage Stance holders get. What deciphering one gives (Scroll of Rat
Familiar, Scroll of Imbue Chillknife...: the scrolls' item_loot_template) was "Classes: Mage" too and asked for no skill: AllowableClass
-1 and the deciphering skill at rank 1, so they stay a mage's.

    tools/stance_scrolls.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ITEM_SPARSE_HASH, ROOT, VERIFIED_BUILD, columns, flat, meta, mysql, sql_value  # noqa: E402

OUT = ROOT / "custom-sql" / "078_deciphering_scrolls_any_class"
FIRST_HOTFIX_ID = 81001854
SCROLLS = [211780, 211785, 211786, 211787, 211784, 211853, 211854, 211855, 213543, 213544, 213545, 213546, 213547,
           281015, 281016, 281017, 281018]


SKILL_DECIPHERING = 3012


def world(query):
    return mysql(query.replace("FROM ", "FROM world.", 1))


def main():
    cols = columns("HOTFIX_SEL_ITEM_SPARSE")
    allowable = cols.index("AllowableClass")
    skill, skill_rank = cols.index("RequiredSkill"), cols.index("RequiredSkillRank")
    sparse, _ = db2read.read(DBC / "ItemSparse.db2", meta("ItemSparse"))
    rewards = sorted({int(r[0]) for r in world(f"SELECT DISTINCT Item FROM item_loot_template WHERE ItemType = 0 AND Entry IN "
                                                  f"({', '.join(map(str, SCROLLS))})")})
    items = SCROLLS + [i for i in rewards if i not in SCROLLS]
    rows = []
    for item_id in items:
        record = [item_id] + flat(sparse[item_id])
        if len(record) != len(cols):
            sys.exit("ItemSparse.db2 does not match the item_sparse columns")
        if record[allowable] != 128:
            sys.exit(f"item {item_id} is not mage-only (AllowableClass {record[allowable]}): check it before changing it")
        record[allowable] = -1
        if item_id not in SCROLLS and not record[skill]:
            record[skill], record[skill_rank] = SKILL_DECIPHERING, 1
        rows.append("(" + ", ".join(sql_value(v) for v in record + [VERIFIED_BUILD]) + ")")
    ids = ", ".join(map(str, items))
    hotfix_ids = range(FIRST_HOTFIX_ID, FIRST_HOTFIX_ID + len(items))
    column_list = ", ".join(f"`{c}`" for c in cols + ["VerifiedBuild"])
    lines = [
        "-- The mage's untranslated scrolls (Comprehend Scroll) and what deciphering them gives, for Mage Stance holders (written by",
        "-- tools/stance_scrolls.py): ItemSparse rows from the client's ItemSparse.db2 with AllowableClass -1 instead of 128 (mage), so",
        "-- a character with Mage Stance can click them; the rewards ask for the deciphering skill 3012 at rank 1 instead, which only",
        "-- mages and Mage Stance holders have (the untranslated scrolls ask for it already).",
        "-- Apply to the `hotfixes` database; restart worldserver. Clients delete their Cache folder.",
        f"DELETE FROM item_sparse WHERE ID IN ({ids});",
        f"INSERT INTO item_sparse ({column_list}) VALUES\n" + ",\n".join(rows) + ";",
        f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};",
        "INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES\n" + ",\n".join(
            f"({h}, {h}, {ITEM_SPARSE_HASH}, {i}, 1, {VERIFIED_BUILD})" for h, i in zip(hotfix_ids, items)) + ";",
    ]
    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")
    Path(f"{OUT}.rollback.sql").write_text("\n".join([
        "-- Apply to the `hotfixes` database; restart worldserver. Clients delete their Cache folder.",
        f"DELETE FROM item_sparse WHERE ID IN ({ids});",
        f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};", ""]))
    print(f"{len(SCROLLS)} scrolls and {len(items) - len(SCROLLS)} rewards, hotfix_data {hotfix_ids.start}-{hotfix_ids.stop - 1}")


if __name__ == "__main__":
    main()
