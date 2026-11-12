#!/usr/bin/env python3
"""Writes custom-sql/066_bonus_tomes_hotfix.sql (and its rollback): the Tome items that grant talent points and bonus stats.

Eighteen new soulbound consumables, each with its own new spell: the Tome of Talent (one talent point, as .talents grant 1)
and one Tome per bonus stat (+1 of that stat, as .bonusstats grant <stat> 1). Neither exists in the client files, so every
record is a hotfix row with a new ID: Item, ItemSparse, ItemEffect and ItemXItemEffect for the item, and SpellName,
SpellMisc, SpellEffect, SpellXSpellVisual and Spell (its description, as a hotfix_blob) for the spell. The item and spell records start from
Scroll of Strength (954) and a self-cast spell with one dummy effect, cast in 1.5 seconds with the visual and sound of
learning a recipe (SpellVisual 222, as spell 402265 that recipes cast); the spells' scripts (spell_bonus_tome_talent
and spell_bonus_tome_stat, custom-sql 067) give the reward. The core's BonusLoot (game/Loot/BonusLoot.h) drops them.

IDs must match BonusLoot.h and the scripts in cs_talentgrant.cpp and cs_bonusstats.cpp. Item and spell N use the same ID,
and so do their ItemEffect, ItemXItemEffect, SpellMisc, SpellEffect and SpellXSpellVisual rows.

The hotfix_data push IDs move to a new range whenever the records change (OLD_HOTFIX_IDS lists the earlier ones, which the
SQL deletes): a client that has cached a record under a push ID does not ask for it again.

    tools/bonus_tomes.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, VERIFIED_BUILD, columns, flat, meta, sql_value  # noqa: E402

OUT = ROOT / "custom-sql" / "066_bonus_tomes_hotfix"
FIRST_HOTFIX_ID = 81001626
OLD_HOTFIX_IDS = [(81001482, 81001625)]     # first version: instant, no visual
CAST_TIME_INDEX = 16         # SpellCastTimes 16: 1.5 seconds (recipes take 3, index 14)
LEARN_VISUAL = 222           # SpellVisual of learning a recipe (spell 402265)
TEMPLATE_ITEM = 954          # Scroll of Strength
TOME_ICON = 133739           # the mage trainer tomes' book
TALENT_ICON = 133741         # the priest codices' book
RARE, EPIC = 3, 4
STACK = 20

HASH = {
    "item": 1344507586, "item_sparse": 2442913102, "item_effect": 1073915313, "item_x_item_effect": 13330255,
    "spell_name": 1187407512, "spell_misc": 3322146344, "spell_effect": 4030871717, "spell": 3776013982,
    "spell_x_spell_visual": 666345498,
}

# (ID, name, use text, quality, icon). The order of the stat Tomes is BONUS_TOMES in cs_bonusstats.cpp.
TOMES = [
    (8104001, "Tome of Talent", "Permanently grants you one additional talent point.", EPIC, TALENT_ICON),
] + [
    (8104002 + n, f"Tome of {title}", f"Permanently increases your {text} by 1.", RARE, TOME_ICON)
    for n, (title, text) in enumerate([
        ("Strength", "Strength"),
        ("Agility", "Agility"),
        ("Stamina", "Stamina"),
        ("Intellect", "Intellect"),
        ("Spirit", "Spirit"),
        ("Hit Rating", "hit rating"),
        ("Critical Strike", "critical strike rating"),
        ("Haste", "haste rating"),
        ("Expertise", "expertise rating"),
        ("Dodge", "dodge rating"),
        ("Parry", "parry rating"),
        ("Block", "block rating"),
        ("Attack Power", "attack power"),
        ("Spell Power", "spell power"),
        ("Armor", "armor"),
        ("Health", "maximum health"),
        ("Mana", "maximum mana"),
    ])
]


def insert(table, cols, rows):
    names = ", ".join(f"`{c}`" for c in cols + ["VerifiedBuild"])
    values = ",\n".join("  (" + ", ".join(sql_value(v) for v in row + [VERIFIED_BUILD]) + ")" for row in rows)
    return f"INSERT INTO {table} ({names}) VALUES\n{values};"


def record(cols, **values):
    """A row for cols: every column 0 unless given."""
    unknown = set(values) - set(cols)
    if unknown:
        sys.exit(f"unknown columns {unknown}")
    return [values.get(c, 0) for c in cols]


def main():
    ids = [t[0] for t in TOMES]
    item_ids, _ = db2read.read(DBC / "Item.db2", meta("Item"))
    sparse, _ = db2read.read(DBC / "ItemSparse.db2", meta("ItemSparse"))
    if set(ids) & set(item_ids):
        sys.exit("a Tome ID is already a client item")
    names = {values[4] for values in sparse.values()}
    if clash := [t[1] for t in TOMES if t[1] in names]:
        sys.exit(f"names already used by client items: {clash}")

    item_cols = columns("HOTFIX_SEL_ITEM")
    sparse_cols = columns("HOTFIX_SEL_ITEM_SPARSE")
    item_template = dict(zip(item_cols, [TEMPLATE_ITEM] + flat(item_ids[TEMPLATE_ITEM])))
    sparse_template = dict(zip(sparse_cols, [TEMPLATE_ITEM] + flat(sparse[TEMPLATE_ITEM])))
    if len(item_template) != len(item_cols) or len(sparse_template) != len(sparse_cols):
        sys.exit("the client files do not match the hotfix columns")

    items, sparses, effects, links, spell_names, miscs, spell_effects, visuals = [], [], [], [], [], [], [], []
    for tome_id, name, text, quality, icon in TOMES:
        items.append([{**item_template, "ID": tome_id, "SubclassID": 8, "IconFileDataID": icon}[c] for c in item_cols])
        sparses.append([{**sparse_template, "ID": tome_id, "Display": name, "Stackable": STACK, "SellPrice": 0,
                         "BuyPrice": 0, "Flags2": 0, "ItemLevel": 1, "RequiredLevel": 0, "Bonding": 1,
                         "OverallQualityID": quality}[c] for c in sparse_cols])
        # on use (TriggerType 0), consumed (Charges -1), the spell's own cooldown (-1)
        effects.append(record(columns("HOTFIX_SEL_ITEM_EFFECT"), ID=tome_id, TriggerType=0, Charges=-1,
                              CoolDownMSec=-1, CategoryCoolDownMSec=-1, SpellID=tome_id))
        links.append(record(columns("HOTFIX_SEL_ITEM_X_ITEM_EFFECT"), ID=tome_id, ItemEffectID=tome_id, ItemID=tome_id))
        spell_names.append([tome_id, name])
        # instant (casting time 1), self only (range 1), physical school
        miscs.append(record(columns("HOTFIX_SEL_SPELL_MISC"), ID=tome_id, CastingTimeIndex=CAST_TIME_INDEX, RangeIndex=1,
                            SchoolMask=1, SpellIconFileDataID=icon, SpellID=tome_id))
        # SPELL_EFFECT_DUMMY (3) on TARGET_UNIT_CASTER (1), 1 point
        spell_effects.append(record(columns("HOTFIX_SEL_SPELL_EFFECT"), ID=tome_id, Effect=3, EffectBasePoints=1,
                                    EffectChainAmplitude=1, PvpMultiplier=1, GroupSizeBasePointsCoefficient=1,
                                    ImplicitTarget1=1, SpellID=tome_id))
        visuals.append(record(columns("HOTFIX_SEL_SPELL_X_SPELL_VISUAL"), ID=tome_id, SpellVisualID=LEARN_VISUAL,
                              Probability=1.0, Priority=1, SpellID=tome_id))

    id_list = ", ".join(map(str, ids))
    tables = [
        ("item", item_cols, items),
        ("item_sparse", sparse_cols, sparses),
        ("item_effect", columns("HOTFIX_SEL_ITEM_EFFECT"), effects),
        ("item_x_item_effect", columns("HOTFIX_SEL_ITEM_X_ITEM_EFFECT"), links),
        ("spell_name", columns("HOTFIX_SEL_SPELL_NAME"), spell_names),
        ("spell_misc", columns("HOTFIX_SEL_SPELL_MISC"), miscs),
        ("spell_effect", columns("HOTFIX_SEL_SPELL_EFFECT"), spell_effects),
        ("spell_x_spell_visual", columns("HOTFIX_SEL_SPELL_X_SPELL_VISUAL"), visuals),
    ]
    hotfixes = [(HASH[table], tome_id) for table, _, _ in tables for tome_id in ids]
    hotfixes += [(HASH["spell"], tome_id) for tome_id in ids]
    hotfix_ids = range(FIRST_HOTFIX_ID, FIRST_HOTFIX_ID + len(hotfixes))

    lines = [
        f"-- The Tome items (written by tools/bonus_tomes.py): Tome of Talent ({ids[0]}) and a Tome per bonus stat",
        f"-- ({ids[1]}-{ids[-1]}), each a new soulbound consumable with its own new spell (same ID). Item records start",
        f"-- from Scroll of Strength ({TEMPLATE_ITEM}); spells are self only with one dummy effect (scripted in 067), cast in",
        "-- 1.5 seconds with the visual and sound of learning a recipe (SpellVisual 222).",
        "-- The Spell record (the tooltip's Use: text) is a hotfix_blob: NameSubtext, Description, AuraDescription.",
        "-- Apply to the `hotfixes` database; restart worldserver. Clients download the hotfixes at login.",
    ]
    rollback = ["-- Apply to the `hotfixes` database; restart worldserver."]
    for table, cols, rows in tables:
        delete = f"DELETE FROM {table} WHERE ID IN ({id_list});"
        lines += [delete, insert(table, cols, rows)]
        rollback.append(delete)
    blob_delete = f"DELETE FROM hotfix_blob WHERE TableHash = {HASH['spell']} AND RecordId IN ({id_list});"
    lines.append(blob_delete)
    lines.append("INSERT INTO hotfix_blob (TableHash, RecordId, locale, `Blob`, VerifiedBuild) VALUES\n" + ",\n".join(
        f"  ({HASH['spell']}, {tome_id}, 'enUS', 0x{(b'\0' + text.encode() + b'\0\0').hex().upper()}, "
        f"{VERIFIED_BUILD})" for tome_id, _, text, _, _ in TOMES) + ";")
    rollback.append(blob_delete)
    hotfix_delete = f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};"
    lines += [f"DELETE FROM hotfix_data WHERE Id BETWEEN {first} AND {last};" for first, last in OLD_HOTFIX_IDS]
    lines.append(hotfix_delete)
    lines.append("INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES\n" + ",\n".join(
        f"  ({h}, {h}, {table_hash}, {record_id}, 1, {VERIFIED_BUILD})"
        for h, (table_hash, record_id) in zip(hotfix_ids, hotfixes)) + ";")
    rollback.append(hotfix_delete)

    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")
    print(f"{len(TOMES)} Tomes {ids[0]}-{ids[-1]}, hotfix_data {hotfix_ids.start}-{hotfix_ids.stop - 1}")


if __name__ == "__main__":
    main()
