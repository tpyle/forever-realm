#!/usr/bin/env python3
"""Writes the class stance talent trees and the ForeverStances addon's data from the client's DB2 files and our hotfixes.

The stance talent trees are WoW Forever's trait trees, the ones the client's own talent window shows (Talent.db2 is the old
Classic data: Forever removed talents such as Improved Devotion Aura, added others such as Divine Intellect and changed
ranks). One TraitTree per class (SkillLineXTraitTree); its three tabs and seven rows come from node groups: a row's gate
group carries a TraitCond "SpentAmountRequired N of currency 3820 in group G", G holding that tab's nodes of the rows above.
The hotfixes database's trait rows are laid over the DB2 rows, as the client does.

  client-addon/ForeverStances/Data/Talents.lua       the trees for the addon's window (tabs named from TalentTab.db2)
  client-addon/ForeverStances/Data/SpellClasses.lua  the class of each spell by spell family (the addon's greyed spells)
  custom-sql/075_class_stance_talent_nodes.sql       world.class_stance_talent: the same trees for the server's rules
  custom-sql/076_class_stance_talents_trait.sql      characters: picks saved by Talent.db2 ID moved to trait node entries

    tools/class_stance_addon_data.py
"""
import struct
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import db2read  # noqa: E402
from reagent_stacks import DBC, ROOT, columns, flat, meta, mysql  # noqa: E402

DATA = ROOT / "client-addon" / "ForeverStances" / "Data"
SQL = ROOT / "custom-sql"
# ChrClasses.SpellClassSet (the spell family) of each class with a stance (ClassStance::Classes)
FAMILY_CLASS = {4: 1, 10: 2, 9: 3, 8: 4, 6: 5, 11: 7, 3: 8, 5: 9, 7: 11}
CLASS_BITS = {1 << (c - 1): c for c in FAMILY_CLASS.values()}
# the class skill lines with a talent tree (SkillLineXTraitTree)
SKILL_CLASS = {26: 1, 184: 2, 50: 3, 38: 4, 613: 5, 373: 7, 237: 8, 354: 9, 574: 11}
TALENT_CURRENCY = 3820
COLUMN_STEP = 600

HEADER = "-- Written by tools/class_stance_addon_data.py from the client's DB2 files and the hotfixes database; do not edit.\n"


def lua_str(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def number(text):
    for kind in (int, float):
        try:
            return kind(text)
        except ValueError:
            pass
    return text


def load(name, statement, hotfix_table=None):
    """{ID: {column: value}} from the DB2 file, with the hotfixes database's valid rows over it and its removed rows gone."""
    cols = [c.strip("`") for c in columns(statement)]
    path = DBC / f"{name}.db2"
    rows, _ = db2read.read(path, meta(name))
    table_hash = struct.unpack_from("<I", open(path, "rb").read(160), 152)[0]
    out = {}
    for record_id, values in rows.items():
        values = flat(values)
        if len(values) == len(cols) - 1:
            values = [record_id] + values
        out[record_id] = dict(zip(cols, values))
    if hotfix_table:
        status = {int(r): int(s) for r, s in mysql(f"SELECT RecordId, Status FROM hotfix_data WHERE TableHash = {table_hash}")}
        for record_id, s in status.items():
            if s == 2:
                out.pop(record_id, None)
        select = ", ".join(f"`{c}`" for c in cols)
        for row in mysql(f"SELECT {select} FROM {hotfix_table}"):
            record = dict(zip(cols, map(number, row)))
            if status.get(record["ID"]) == 1:
                out[record["ID"]] = record
    return out


class UnionFind:
    def __init__(self):
        self.parent = {}

    def find(self, x):
        self.parent.setdefault(x, x)
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a, b):
        self.parent[self.find(a)] = self.find(b)


def build_trees():
    skill_trees = load("SkillLineXTraitTree", "HOTFIX_SEL_SKILL_LINE_X_TRAIT_TREE", "skill_line_x_trait_tree")
    nodes = load("TraitNode", "HOTFIX_SEL_TRAIT_NODE", "trait_node")
    node_x_entry = load("TraitNodeXTraitNodeEntry", "HOTFIX_SEL_TRAIT_NODE_X_TRAIT_NODE_ENTRY", "trait_node_x_trait_node_entry")
    entries = load("TraitNodeEntry", "HOTFIX_SEL_TRAIT_NODE_ENTRY", "trait_node_entry")
    definitions = load("TraitDefinition", "HOTFIX_SEL_TRAIT_DEFINITION", "trait_definition")
    edges = load("TraitEdge", "HOTFIX_SEL_TRAIT_EDGE", "trait_edge")
    group_nodes = load("TraitNodeGroupXTraitNode", "HOTFIX_SEL_TRAIT_NODE_GROUP_X_TRAIT_NODE", "trait_node_group_x_trait_node")
    group_conds = load("TraitNodeGroupXTraitCond", "HOTFIX_SEL_TRAIT_NODE_GROUP_X_TRAIT_COND", "trait_node_group_x_trait_cond")
    conds = load("TraitCond", "HOTFIX_SEL_TRAIT_COND", "trait_cond")

    members = defaultdict(set)                      # group -> nodes
    for r in group_nodes.values():
        members[r["TraitNodeGroupID"]].add(r["TraitNodeID"])
    node_entry = {}                                 # node -> its (single) entry
    for r in sorted(node_x_entry.values(), key=lambda r: r["Index"]):
        if r["TraitNodeEntryID"] in entries:
            node_entry.setdefault(r["TraitNodeID"], r["TraitNodeEntryID"])
    parents = defaultdict(list)                     # node -> prerequisite nodes
    for r in edges.values():
        parents[r["RightTraitNodeID"]].append(r["LeftTraitNodeID"])

    trees = {}
    for r in skill_trees.values():
        class_id = SKILL_CLASS.get(r["SkillLineID"])
        if not class_id:
            continue
        tree_nodes = {n for n, row in nodes.items() if row["TraitTreeID"] == r["TraitTreeID"] and n in node_entry}

        # gates: the points a node's row asks in its tab, and the tabs (nodes counted together, with the rows they open)
        need = defaultdict(int)
        tabs = UnionFind()
        for n in tree_nodes:
            tabs.find(n)
        for link in group_conds.values():
            cond = conds.get(link["TraitCondID"])
            if not cond or cond["TraitCurrencyID"] != TALENT_CURRENCY or not cond["SpentAmountRequired"]:
                continue
            gated = members[link["TraitNodeGroupID"]] & tree_nodes
            counted = members[cond["TraitNodeGroupID"]] & tree_nodes
            for n in gated:
                need[n] = max(need[n], cond["SpentAmountRequired"])
            together = sorted(gated | counted)
            for n in together[1:]:
                tabs.union(together[0], n)
        by_tab = defaultdict(list)
        for n in tree_nodes:
            by_tab[tabs.find(n)].append(n)
        trees[class_id] = {"tree": r["TraitTreeID"], "tabs": list(by_tab.values()), "need": need}

    def node_info(n):
        entry = node_entry[n]
        e = entries[entry]
        d = definitions.get(e["TraitDefinitionID"], {})
        return {"node": n, "entry": entry, "definition": e["TraitDefinitionID"], "spell": d.get("SpellID", 0),
                "max": e["MaxRanks"], "x": nodes[n]["PosX"], "y": nodes[n]["PosY"]}

    return trees, node_info, parents, node_entry


def main():
    trees, node_info, parents, node_entry = build_trees()

    def nodes_x(n):
        return node_info(n)["x"]
    tabs_db2, _ = db2read.read(DBC / "TalentTab.db2", meta("TalentTab"))
    talents_db2, _ = db2read.read(DBC / "Talent.db2", meta("Talent"))
    # Talent.db2's rank 1 spell -> its tab, to name the trait tabs (TalentTab: Name, BackgroundFile, Description, OrderIndex,
    # RaceMask, ClassMask, PetTalentMask, IconFileDataID, ...)
    spell_tab, spell_column = {}, {}
    for row in talents_db2.values():
        ranks = [s for s in row[11] if s]
        if ranks:
            spell_tab[ranks[0]] = row[4]
            spell_column[ranks[0]] = row[3]

    classes = {}
    warnings = []
    old_to_entry = {}               # Talent.db2 ID -> trait node entry (the migration of saved picks)
    for class_id, tree in sorted(trees.items()):
        # the tabs left to right (each sits in its own band of x), named in the class's TalentTab order (OrderIndex); the
        # spells' old tabs do not name them: Forever moved talents between trees
        named = sorted((row[3], tab_id) for tab_id, row in tabs_db2.items() if CLASS_BITS.get(row[5]) == class_id)
        ordered = sorted(tree["tabs"], key=lambda ns: sorted(nodes_x(n) for n in ns)[len(ns) // 2])
        if len(ordered) != 3 or len(named) != 3:
            warnings.append(f"class {class_id}: {len(ordered)} trait tabs, {len(named)} TalentTabs")
        tabs = [(named[k][1] if k < len(named) else 0, [node_info(n) for n in ns]) for k, ns in enumerate(ordered)]

        out_tabs = []
        for tab_index, (tab_id, infos) in enumerate(tabs):
            xs = sorted(i["x"] for i in infos)
            median = xs[len(xs) // 2]
            base = min(x for x in xs if abs(x - median) < 2500)
            # a node placed off the tree's grid is hidden: an old talent moved away by a hotfix that adds its replacement (hunter
            # 104982 at y 39300, priest 105865 at y 21300); the client does not show it, so neither do we
            hidden = [i for i in infos if abs(i["x"] - median) >= 2500 or not 1500 <= i["y"] <= 7000]
            for i in hidden:
                warnings.append(f"class {class_id} tab {tab_index}: node {i['node']} at {i['x']},{i['y']} is off the grid: left out")
            infos = [i for i in infos if i not in hidden]
            cells = {}
            placed = []
            for i in sorted(infos, key=lambda i: (tree["need"][i["node"]], i["x"])):
                tier = tree["need"][i["node"]] // 5
                column = round((i["x"] - base) / COLUMN_STEP)
                if not 0 <= column <= 3:
                    # a position outside its tab (hunter 104982 at x 102800): the old talent's column, else the nearest edge
                    if i["spell"] in spell_column:
                        column = spell_column[i["spell"]]
                        warnings.append(f"class {class_id} tab {tab_index}: node {i['node']} at x {i['x']}: Talent.db2 column {column}")
                    else:
                        warnings.append(f"class {class_id} tab {tab_index}: node {i['node']} at x {i['x']} clamped into the grid")
                column = min(max(column, 0), 3)
                if (tier, column) in cells:
                    free = [c for c in range(4) if (tier, c) not in cells]
                    warnings.append(f"class {class_id} tab {tab_index}: node {i['node']} shares row {tier} column {column} "
                                    f"with node {cells[(tier, column)]}, moved to {free[0] if free else '?'}")
                    column = free[0] if free else column
                cells[(tier, column)] = i["node"]
                prereqs = [node_entry[p] for p in parents.get(i["node"], []) if p in node_entry]
                placed.append({**i, "tier": tier, "column": column, "need": tree["need"][i["node"]], "tab": tab_index,
                               "prereqs": prereqs})
            row = tabs_db2.get(tab_id)
            out_tabs.append({"id": tab_id, "name": row[0] if row else f"Tree {tab_index + 1}",
                             "background": row[1] if row else "", "icon": row[7] if row else 0, "talents": placed})
        classes[class_id] = out_tabs

        # the migration: an old pick's rank 1 spell is a node's spell
        by_spell = {t["spell"]: t["entry"] for tab in out_tabs for t in tab["talents"]}
        for talent_id, row in talents_db2.items():
            ranks = [s for s in row[11] if s]
            tab = tabs_db2.get(row[4])
            if ranks and ranks[0] in by_spell and tab and CLASS_BITS.get(tab[5]) == class_id:
                old_to_entry[talent_id] = by_spell[ranks[0]]

    max_by_entry = {t["entry"]: t["max"] for tabs in classes.values() for tab in tabs for t in tab["talents"]}

    # the addon
    lines = [HEADER, "local _, ns = ...",
             "-- [class] = { tabs in order: { id (TalentTab), name, background, icon, talents = {",
             "--   { id = entry (trait node entry), tier, column (0-based), need (points in the tab the row asks), max (ranks),",
             "--     spell (the trait's spell: name, icon), prereqs = { { talent, rank } } } } } }",
             "ns.Talents = {"]
    count = 0
    for class_id, tabs in classes.items():
        lines.append(f"  [{class_id}] = {{")
        for tab in tabs:
            lines.append(f"    {{ id = {tab['id']}, name = {lua_str(tab['name'])}, background = {lua_str(tab['background'])}, "
                         f"icon = {tab['icon']}, talents = {{")
            for t in sorted(tab["talents"], key=lambda t: (t["tier"], t["column"])):
                pre = ", ".join(f"{{ {p}, {max_by_entry.get(p, 1)} }}" for p in t["prereqs"])
                lines.append(f"      {{ id = {t['entry']}, entry = {t['entry']}, tier = {t['tier']}, column = {t['column']}, "
                             f"need = {t['need']}, max = {t['max']}, spell = {t['spell']}, prereqs = {{ {pre} }} }},")
                count += 1
            lines.append("    } },")
        lines.append("  },")
    lines.append("}")
    DATA.mkdir(parents=True, exist_ok=True)
    (DATA / "Talents.lua").write_text("\n".join(lines) + "\n")

    # the server
    rows = []
    for class_id, tabs in classes.items():
        for tab in tabs:
            for t in tab["talents"]:
                pre = (t["prereqs"] + [0, 0, 0])[:3]
                rows.append(f"({class_id}, {t['entry']}, {t['node']}, {t['definition']}, {t['spell']}, {t['tab']}, {t['tier']}, "
                            f"{t['need']}, {t['max']}, {pre[0]}, {pre[1]}, {pre[2]})")
    (SQL / "075_class_stance_talent_nodes.sql").write_text("\n".join([
        "-- Class stance talents (core ClassStance.h, the ForeverStances addon): WoW Forever's trait trees, one per class, as the",
        "-- client's own talent window shows them, written by tools/class_stance_addon_data.py from the DB2 files and hotfixes.",
        "-- entry: the trait node entry (what a pick is saved as); spell and definition: what is learned, with the rank as a trait;",
        "-- tab 0-2 and tier 0-6; need: the points in the tab the row asks; prereq1-3: entries that must be at their full rank.",
        "-- Apply to the `world` database; restart worldserver (read at startup).",
        "CREATE TABLE IF NOT EXISTS class_stance_talent (",
        "  class TINYINT UNSIGNED NOT NULL, entry INT UNSIGNED NOT NULL, node INT UNSIGNED NOT NULL,",
        "  definition INT UNSIGNED NOT NULL, spell INT UNSIGNED NOT NULL, tab TINYINT UNSIGNED NOT NULL,",
        "  tier TINYINT UNSIGNED NOT NULL, need TINYINT UNSIGNED NOT NULL, max_ranks TINYINT UNSIGNED NOT NULL,",
        "  prereq1 INT UNSIGNED NOT NULL DEFAULT 0, prereq2 INT UNSIGNED NOT NULL DEFAULT 0, prereq3 INT UNSIGNED NOT NULL DEFAULT 0,",
        "  PRIMARY KEY (entry), KEY idx_class (class)",
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
        "DELETE FROM class_stance_talent;",
        "INSERT INTO class_stance_talent (class, entry, node, definition, spell, tab, tier, need, max_ranks, prereq1, prereq2, prereq3) VALUES",
        ",\n".join(rows) + ";", ""]))
    (SQL / "075_class_stance_talent_nodes.rollback.sql").write_text(
        "-- Apply to the `world` database; restart worldserver.\nDROP TABLE IF EXISTS class_stance_talent;\n")

    # the saved picks (characters, one-off)
    cases = " ".join(f"WHEN {old} THEN {new}" for old, new in sorted(old_to_entry.items()))
    caps = " ".join(f"WHEN {e} THEN {m}" for e, m in sorted(max_by_entry.items()))
    (SQL / "076_class_stance_talents_trait.sql").write_text("\n".join([
        "-- Class stance talents moved from Talent.db2 IDs to trait node entries (075): a pick whose talent is in WoW Forever's",
        "-- trees takes its node entry, its rank capped at the trait's ranks; a pick of a talent Forever removed is deleted (its",
        "-- points come back). Written by tools/class_stance_addon_data.py. Talent.db2 IDs are below 100000, node entries above.",
        "-- Apply to the `characters` database once, with worldserver stopped (it would save the old IDs back).",
        f"UPDATE character_class_stance_talent SET talent = CASE talent {cases} ELSE 0 END WHERE talent < 100000;",
        "DELETE FROM character_class_stance_talent WHERE talent = 0;",
        f"UPDATE character_class_stance_talent SET `rank` = LEAST(`rank`, CASE talent {caps} ELSE `rank` END);",
        ""]))
    (SQL / "076_class_stance_talents_trait.rollback.sql").write_text(
        "-- Apply to the `characters` database with worldserver stopped. The old Talent.db2 picks cannot be rebuilt from the\n"
        "-- node entries: this clears the stance talents (every point comes back).\nDELETE FROM character_class_stance_talent;\n")

    # the greyed spells, less those cast in any stance (ClassStance.AnyStanceSpells in tools/apply_config.py)
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from apply_config import SETTINGS
    any_stance = {int(x) for x in SETTINGS["worldserver.conf"]["ClassStance.AnyStanceSpells"].split()}
    options, _ = db2read.read(DBC / "SpellClassOptions.db2", meta("SpellClassOptions"))
    spells = {}
    family = {}
    for row in options.values():
        values = flat(row)
        family[values[0]] = values[2]
        class_id = FAMILY_CLASS.get(values[2])
        if class_id and values[0] and values[0] not in any_stance:
            spells[values[0]] = class_id
    # a spell of no family (Rockbiter Weapon): the class of its class skill line, when that line belongs to one class
    # (ClassStance's GetClassOfSpell)
    skill_lines = load("SkillLine", "HOTFIX_SEL_SKILL_LINE", "skill_line")
    masks = defaultdict(int)
    for row in load("SkillRaceClassInfo", "HOTFIX_SEL_SKILL_RACE_CLASS_INFO", "skill_race_class_info").values():
        line = skill_lines.get(row["SkillID"])
        if line and line["CategoryID"] == 7:
            masks[row["SkillID"]] |= row["ClassMask"] & 0xFFFFFFFF
    line_class = {skill: CLASS_BITS[mask] for skill, mask in masks.items() if mask in CLASS_BITS}
    for row in sorted(load("SkillLineAbility", "HOTFIX_SEL_SKILL_LINE_ABILITY", "skill_line_ability").values(), key=lambda r: r["ID"]):
        spell = row["Spell"]
        if spell and not family.get(spell) and spell not in spells and spell not in any_stance and row["SkillLine"] in line_class:
            spells[spell] = line_class[row["SkillLine"]]
    out = [HEADER, "local _, ns = ...", "-- [spell] = class of its spell family (or of its class skill line)", "ns.SpellClasses = {"]
    items = sorted(spells.items())
    for i in range(0, len(items), 12):
        out.append("  " + " ".join(f"[{s}]={c}," for s, c in items[i:i + 12]))
    out.append("}")
    (DATA / "SpellClasses.lua").write_text("\n".join(out) + "\n")

    for class_id, tabs in classes.items():
        print(f"class {class_id}: " + ", ".join(f"{t['name']} {len(t['talents'])}" for t in tabs)
              + f" = {sum(len(t['talents']) for t in tabs)} talents")
    for w in warnings:
        print("  " + w)
    print(f"{count} talents, {len(old_to_entry)} old talents mapped, {len(spells)} class spells")


if __name__ == "__main__":
    main()
