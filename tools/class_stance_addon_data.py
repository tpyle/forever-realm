#!/usr/bin/env python3
"""Writes the data files of the ForeverStances addon (client-addon/ForeverStances/Data/) from the client's DB2 files.

Talents.lua: every class's three talent tabs (TalentTab: name, background, icon, order) and talents (Talent: tier, column,
rank spells, prerequisites), so the addon can draw another class's trees; the client's talent API knows the real class only.
SpellClasses.lua: the class of every spell of a class spell family (SpellClassOptions.SpellClassSet), the rule the server's
ClassStance::GetClassOfSpell uses, so the addon can grey out abilities that do not fit the active class stance.

    tools/class_stance_addon_data.py
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, flat, meta  # noqa: E402

OUT = ROOT / "client-addon" / "ForeverStances" / "Data"
# ChrClasses.SpellClassSet (the spell family) of each class with a stance (ClassStance::Classes)
FAMILY_CLASS = {4: 1, 10: 2, 9: 3, 8: 4, 6: 5, 11: 7, 3: 8, 5: 9, 7: 11}
CLASS_BITS = {1 << (c - 1): c for c in FAMILY_CLASS.values()}

HEADER = "-- Written by tools/class_stance_addon_data.py from the client's DB2 files; do not edit.\n"


def lua_str(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    tabs, _ = db2read.read(DBC / "TalentTab.db2", meta("TalentTab"))
    talents, _ = db2read.read(DBC / "Talent.db2", meta("Talent"))
    options, _ = db2read.read(DBC / "SpellClassOptions.db2", meta("SpellClassOptions"))

    # TalentTab: Name, BackgroundFile, Description, OrderIndex, RaceMask, ClassMask, PetTalentMask, IconFileDataID, ...
    by_class = {}
    for tab_id, row in tabs.items():
        class_id = CLASS_BITS.get(row[5])
        if class_id:
            by_class.setdefault(class_id, []).append((row[3], tab_id, row))

    # Talent: Description, TierID, Flags, ColumnIndex, TabID, ClassID, SpecID, SpellID, OverridesSpellID, RequiredSpellID,
    # CategoryMask[2], SpellRank[9], PrereqTalent[3], PrereqRank[3]
    by_tab = {}
    for talent_id, row in talents.items():
        ranks = [s for s in row[11] if s]
        if not ranks:
            continue
        prereqs = [(t, r) for t, r in zip(row[12], row[13]) if t]
        by_tab.setdefault(row[4], []).append((row[1], row[3], talent_id, ranks, prereqs))

    lines = [HEADER, "local _, ns = ...", "-- [class] = { tabs in order: { id, name, background, icon, talents = {",
             "--   { id, tier (0-based), column (0-based), ranks = { spell per rank }, prereqs = { { talent, rank } } } } } }",
             "ns.Talents = {"]
    count = 0
    for class_id in sorted(by_class):
        lines.append(f"  [{class_id}] = {{")
        for _, tab_id, row in sorted(by_class[class_id]):
            lines.append(f"    {{ id = {tab_id}, name = {lua_str(row[0])}, background = {lua_str(row[1])}, icon = {row[7]}, talents = {{")
            for tier, column, talent_id, ranks, prereqs in sorted(by_tab.get(tab_id, [])):
                pre = ", ".join(f"{{ {t}, {r + 1} }}" for t, r in prereqs)
                lines.append(f"      {{ id = {talent_id}, tier = {tier}, column = {column}, ranks = {{ {', '.join(map(str, ranks))} }}, "
                             f"prereqs = {{ {pre} }} }},")
                count += 1
            lines.append("    } },")
        lines.append("  },")
    lines.append("}")
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "Talents.lua").write_text("\n".join(lines) + "\n")

    spells = {}
    for row in options.values():
        values = flat(row)
        class_id = FAMILY_CLASS.get(values[2])
        if class_id and values[0]:
            spells[values[0]] = class_id
    out = [HEADER, "local _, ns = ...", "-- [spell] = class of its spell family", "ns.SpellClasses = {"]
    items = sorted(spells.items())
    for i in range(0, len(items), 12):
        out.append("  " + " ".join(f"[{s}]={c}," for s, c in items[i:i + 12]))
    out.append("}")
    (OUT / "SpellClasses.lua").write_text("\n".join(out) + "\n")
    print(f"{sum(len(v) for v in by_class.values())} tabs, {count} talents, {len(spells)} class spells")


if __name__ == "__main__":
    main()
