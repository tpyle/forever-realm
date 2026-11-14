#!/usr/bin/env python3
"""Writes custom-sql/071_class_stances_hotfix.sql (and its rollback): the class stance spells and a slot for every resource.

Class stances (TrinityCore game/Entities/Player/ClassStance.h): a player buys another class's stance from that class's
trainer (custom-sql 072) and fights as that class while it is active. Nine new spells, 8104019-8104027 in the order of
ClassStance::Classes (warrior paladin hunter rogue priest shaman mage warlock druid). Each is an instant self cast with
an endless dummy aura (spell_class_stance, 072), on the stance bar (a SpellShapeshift row with a StanceBarOrder, as the
paladin auras have, no shapeshift form), with the class's icon. The records start from Retribution Aura (7294).

ChrClassesXPowerTypes: the client and the server give a class a slot only for the resources listed for it (the druid
has mana, rage, energy and combo points; the mage mana and combo points). New rows give every class all four, so a
stance can show and spend its class's resource. A class's slots are ordered by resource type, so a warrior's rage moves
from slot 0 to slot 1: a saved value there is read as mana once, and rage starts again from 0.

    tools/class_stances.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, VERIFIED_BUILD, columns, meta, sql_value  # noqa: E402

OUT = ROOT / "custom-sql" / "071_class_stances_hotfix"
FIRST_SPELL = 8104019
FIRST_POWER_ROW = 8104101            # ChrClassesXPowerTypes rows
FIRST_HOTFIX_ID = 81001788
TEMPLATE_SPELL = 7294                # Retribution Aura: instant, endless, self
STANCE_BAR_ORDER = 11                # after a class's own stances and auras (1-7)
POWERS = [0, 1, 3, 4]                # mana, rage, energy, combo points

# (class ID, name, what fighting as it gives)
CLASSES = [
    (1, "Warrior", "rage"),
    (2, "Paladin", "mana"),
    (3, "Hunter", "mana"),
    (4, "Rogue", "energy and combo points"),
    (5, "Priest", "mana"),
    (7, "Shaman", "mana"),
    (8, "Mage", "mana"),
    (9, "Warlock", "mana"),
    (11, "Druid", "mana"),
]

HASH = {
    "spell_name": 1187407512, "spell_misc": 3322146344, "spell_effect": 4030871717, "spell": 3776013982,
    "spell_shapeshift": 3163679255, "chr_classes_x_power_types": 3224459983,
}


def flat(values):
    out = []
    for value in values:
        out += value if isinstance(value, list) else [value]
    return out


def insert(table, cols, rows):
    names = ", ".join(f"`{c}`" for c in cols + ["VerifiedBuild"])
    values = ",\n".join("  (" + ", ".join(sql_value(v) for v in row + [VERIFIED_BUILD]) + ")" for row in rows)
    return f"INSERT INTO {table} ({names}) VALUES\n{values};"


def record(cols, **values):
    unknown = set(values) - set(cols)
    if unknown:
        sys.exit(f"unknown columns {unknown}")
    return [values.get(c, 0) for c in cols]


def main():
    misc_cols = columns("HOTFIX_SEL_SPELL_MISC")
    misc, _ = db2read.read(DBC / "SpellMisc.db2", meta("SpellMisc"))
    template = next(dict(zip(misc_cols, [i] + flat(v))) for i, v in misc.items() if flat(v)[-1] == TEMPLATE_SPELL)
    classes, _ = db2read.read(DBC / "ChrClasses.db2", meta("ChrClasses"))
    powers, _ = db2read.read(DBC / "ChrClassesXPowerTypes.db2", meta("ChrClassesXPowerTypes"))
    have = {(v[1], v[0]) for v in powers.values()}     # (class, power)

    ids = [FIRST_SPELL + n for n in range(len(CLASSES))]
    if set(ids) & {flat(v)[-1] for v in misc.values()}:
        sys.exit("a stance spell ID is already a client spell")

    spell_names, miscs, effects, shapeshifts, blobs = [], [], [], [], []
    for spell_id, (class_id, name, resource) in zip(ids, CLASSES):
        icon = classes[class_id][12]                    # ChrClasses.IconFileDataID
        spell_names.append([spell_id, f"{name} Stance"])
        # Retribution Aura's attributes (Attributes3 = SPELL_ATTR2_USE_SHAPESHIFT_BAR puts it on the stance bar) without
        # SPELL_ATTR0_NOT_SHAPESHIFTED (0x10000), so a druid in a form or a warrior in a stance can change class too
        miscs.append([{**template, "ID": spell_id, "SpellID": spell_id, "SchoolMask": 1, "SpellIconFileDataID": icon,
                       "Attributes1": template["Attributes1"] & ~0x10000}[c] for c in misc_cols])
        # SPELL_EFFECT_APPLY_AURA (6), SPELL_AURA_DUMMY (4) on TARGET_UNIT_CASTER (1); the misc value is the class
        effects.append(record(columns("HOTFIX_SEL_SPELL_EFFECT"), ID=spell_id, Effect=6, EffectAura=4, EffectMiscValue1=class_id,
                              EffectChainAmplitude=1, PvpMultiplier=1, GroupSizeBasePointsCoefficient=1, ImplicitTarget1=1,
                              SpellID=spell_id))
        shapeshifts.append(record(columns("HOTFIX_SEL_SPELL_SHAPESHIFT"), ID=spell_id, SpellID=spell_id,
                                  StanceBarOrder=STANCE_BAR_ORDER + len(shapeshifts)))
        description = (f"Fight as a {name}: {resource}, and the {name.lower()}'s attack power, critical strike, dodge and "
                       f"regeneration. Use the {name.lower()} spells you have learned from {name} trainers. Cast again to "
                       "return to your own class.")
        blobs.append((spell_id, b"\0" + description.encode() + b"\0" + f"Fighting as a {name}.".encode() + b"\0"))

    power_rows = []
    for class_id, _, _ in CLASSES:
        for power in POWERS:
            if (class_id, power) not in have:
                power_rows.append([FIRST_POWER_ROW + len(power_rows), power, class_id])
    power_ids = [row[0] for row in power_rows]

    tables = [
        ("spell_name", columns("HOTFIX_SEL_SPELL_NAME"), spell_names, ids),
        ("spell_misc", misc_cols, miscs, ids),
        ("spell_effect", columns("HOTFIX_SEL_SPELL_EFFECT"), effects, ids),
        ("spell_shapeshift", columns("HOTFIX_SEL_SPELL_SHAPESHIFT"), shapeshifts, ids),
        ("chr_classes_x_power_types", columns("HOTFIX_SEL_CHR_CLASSES_X_POWER_TYPES"), power_rows, power_ids),
    ]
    hotfixes = [(HASH[table], record_id) for table, _, _, record_ids in tables for record_id in record_ids]
    hotfixes += [(HASH["spell"], spell_id) for spell_id in ids]
    hotfix_ids = range(FIRST_HOTFIX_ID, FIRST_HOTFIX_ID + len(hotfixes))

    lines = [
        f"-- Class stances (written by tools/class_stances.py): the stance spells {ids[0]}-{ids[-1]} (warrior, paladin, hunter,",
        "-- rogue, priest, shaman, mage, warlock, druid), instant self casts with an endless dummy aura on the stance bar, and",
        "-- ChrClassesXPowerTypes rows that give every class a slot for mana, rage, energy and combo points.",
        "-- Apply to the `hotfixes` database; restart worldserver. Clients delete their Cache folder.",
    ]
    rollback = ["-- Apply to the `hotfixes` database; restart worldserver."]
    for table, cols, rows, record_ids in tables:
        delete = f"DELETE FROM {table} WHERE ID IN ({', '.join(map(str, record_ids))});"
        lines += [delete, insert(table, cols, rows)]
        rollback.append(delete)
    blob_delete = f"DELETE FROM hotfix_blob WHERE TableHash = {HASH['spell']} AND RecordId IN ({', '.join(map(str, ids))});"
    lines.append(blob_delete)
    lines.append("INSERT INTO hotfix_blob (TableHash, RecordId, locale, `Blob`, VerifiedBuild) VALUES\n" + ",\n".join(
        f"  ({HASH['spell']}, {spell_id}, 'enUS', 0x{blob.hex().upper()}, {VERIFIED_BUILD})" for spell_id, blob in blobs) + ";")
    rollback.append(blob_delete)
    hotfix_delete = f"DELETE FROM hotfix_data WHERE Id BETWEEN {hotfix_ids.start} AND {hotfix_ids.stop - 1};"
    lines.append(hotfix_delete)
    lines.append("INSERT INTO hotfix_data (Id, UniqueId, TableHash, RecordId, Status, VerifiedBuild) VALUES\n" + ",\n".join(
        f"  ({h}, {h}, {table_hash}, {record_id}, 1, {VERIFIED_BUILD})"
        for h, (table_hash, record_id) in zip(hotfix_ids, hotfixes)) + ";")
    rollback.append(hotfix_delete)

    Path(f"{OUT}.sql").write_text("\n".join(lines) + "\n")
    Path(f"{OUT}.rollback.sql").write_text("\n".join(rollback) + "\n")
    print(f"{len(ids)} stances {ids[0]}-{ids[-1]}, {len(power_rows)} power rows, hotfix_data {hotfix_ids.start}-{hotfix_ids.stop - 1}")


if __name__ == "__main__":
    main()
