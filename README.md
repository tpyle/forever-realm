# WoW Forever realm

A TrinityCore realm for the WoW Forever client (Classic 1.60.1, builds 70790
and 70862), built from the `forever` branch of advocaite/TrinityCore. It runs
on the same machine as the WotLK realm in `/opt/wow/classic`, sharing its
MySQL server. Rules for working on it are in `AGENTS.md`.

## Layout

| Path | What it is |
|---|---|
| `TrinityCore/` | The core, repository `tpyle/TrinityCore`, branch `trunk` |
| `build/` | CMake build tree (gcc-14) |
| `server/` | Install: `bin/`, generated `etc/`, extracted `data/`, `logs/` |
| `custom-sql/` | Every change to the databases, numbered, with rollbacks |
| `client-addon/` | Addons the client needs, copied to `_forever_/Interface/AddOns/` |
| `tools/` | `apply_config.py`, systemd units, the certificate hook |
| `client/` | Not kept: copy the game client here again to re-extract maps (gitignored) |

## Login and ports

The client's portal is `wow.thomaspyle.com`, port-forwarded to this machine.
The client runs under Proton, which ignores `/etc/hosts`, so the name has to
resolve through real DNS.

| Port (TCP) | Server |
|---|---|
| 1119 | bnetserver (Battle.net login) |
| 8081 | bnetserver REST login |
| 8125 | worldserver (8085 is the WotLK server) |

The login certificate is Let's Encrypt for `wow.thomaspyle.com` (DNS-01 via
Route 53, credentials in `/root/.aws/credentials`). `certbot.timer` renews
it, and `tools/letsencrypt/forever-bnet.sh`, installed as
`/etc/letsencrypt/renewal-hooks/deploy/forever-bnet.sh`, copies it to
`server/bin/wow.{cert,key}.pem` and restarts bnetserver. (A private CA was
used at first and has been deleted; `bnetserver.{cert,key}.pem` in
`server/bin` are TrinityCore's stock files and are not used.)

## Client builds

The realm moved to build 70862 with upstream's
`sql/custom/auth/2026_11_07_00_auth_classic_70862.sql`. Clients still on
70790 are let in by `Realm.AlsoAcceptBuilds = "70790"`, which has to be in
both config files: bnetserver uses it for the realm list, and worldserver
for the realm queries the client makes in game. With it only in
bnetserver.conf, logging in worked but character creation never finished
(the character was saved, the button stayed greyed out).

## Customizations

Apply each `custom-sql/` file to the database it names, in order, then
restart `forever-world`.

### Every race can be every class (001-003, 012-013)

The client offers the combinations listed in its `CharBaseInfo.db2`; adding
a row through `hotfixes.char_base_info` (with a `hotfix_data` entry, table
hash 812099832) unlocks one. The server needs `class_expansion_requirement`,
`playercreateinfo` (start location, copied from the race's warrior) and
`playercreateinfo_action`. Starting gear is `CharacterLoadout` (Purpose 9 for
new characters, with a Purpose 1 mirror) and `CharacterLoadoutItem`, also as
hotfixes. Race mask bits are race - 1, and 32/33 for the two Sky Elf races
(95, 96).

The client has ten playable races and nine classes, so 90 combinations; 56
were stock. 001-003 added orc paladin by hand, 012-013 (generated) the other
33, including undead paladin, which the client offered but the server lacked.
Each class's new races share one gear kit, taken from a stock one.

Holy Light is race-locked in the client data (human and dwarf learn it at
creation, undead can train it), so other paladin races get it from
`playercreateinfo_spell_custom`, which needs `PlayerStart.AllSpells = 1`.

Confirmed in game: creation of the new combinations, Holy Light for new
paladin races, the new trainers, Sky Elves, and human bear form.

Weapon skills (021): `SkillRaceClassInfo` says which races and classes may
have a skill, and whether they start with it (Availability 1) or train it at
a weapon master (0). With no matching row a character can never have it,
and weapon masters show it as unavailable. The new druids (Maces, Daggers),
undead and gnome hunters (Axes, Guns) and Sky Elf paladins, warlocks and
priests (Swords, Two-Handed Swords, Daggers) had none, so 021 adds trainable
rows, plus Bows from the start for undead and gnome hunters, whose starting
kit has a bow. Every new combination can use its starting gear.

Every weapon for everyone (022-023): every race and class can train all 15
weapon skills at a weapon master. That needs three things: a trainable
`SkillRaceClassInfo` row per skill for all classes and races; copies of the
weapon spells' `SkillLineAbility` rows for the classes they leave out (the
spells are class-limited too, including Shoot Bow/Gun/Crossbow, Throw and
Shoot, which come with the skill; hunters keep Auto Shot instead of the three
Shoot spells); and Wands at every weapon master, since only casters had it and
no trainer taught it. Each weapon master still teaches only its own weapons.

Known gaps: some starting zones have no trainer for the new classes; paladin
chargers and priest racial spells stay race-locked.

### Trainers for the new classes (005-007, 014-020)

Shaman and paladin trainers in every capital that lacked them, copied from
stock trainers and given random appearances: Rowan Stormcaller (Stormwind),
Korrin Stonecaller (Ironforge), Aerin Windcaller and Selen Dawnward
(Darnassus), Tahna Sunhoof (Thunder Bluff), Morwen Gravecaller and Alric
Ashward (Undercity), Durga Lightsworn (Orgrimmar, Valley of Honor) and
Korgath the Redeemed (Valley of Trials, by the orc and troll start).
Shaman trainers use trainer list 10 and menu 5123, paladin ones list 29 and
menu 4663.

### Every profession (008-011, `npc_profession_tutor`, ForeverProfessions)

`MaxPrimaryTradeSkill = 11` lets a character have every primary profession,
but the client's trainer window stops at two. Fizzle Everhand, a goblin in
Gadgetzan, teaches them through a gossip menu instead
(`npc_profession_tutor` in the core). The client's professions pane also
shows only two, so the `ForeverProfessions` addon lists them all (`/prof`)
and creates a macro for each one with a window. Both work in game, and
normal trainers sell the higher ranks of a third or later profession.

Fizzle first could not be clicked: the server hides the gossip flag from an
NPC with no gossip menu in the database, even when a script provides the
menu. 009 gives him one.

### Talent points beyond levelling (024-025, `cs_talentgrant`)

    .talents show  [player]            granted points, and total / spent / unspent
    .talents grant <count> [player]    add to the grant
    .talents take  <count> [player]    subtract from it
    .talents set   <count> [player]    set it outright

Omit the player to use your target or yourself. Online characters only.

Talents here are the trait system: talent points are trait currency 3820, and
the client adds up its sources (`TraitCurrencySource`, one point per level
10-60) itself. A server-side bonus would never reach it, so each granted point
is a hidden marker quest (9100001-9100249, flagged as a tracking event so it
never shows in the quest log) with a source worth one point. The command
completes or removes those quests; the client sees them through the
quest-completed bits (`QuestV2.UniqueBitFlag` 72701 onwards), and they are
saved with the character, so the points survive level-ups, relogs and talent
resets. The currency's cap (`TraitCurrency.SourcedMax`) is raised from 51 to
300, so at most 249 points can be granted. Taking away points that are
already spent is refused; reset talents first.

Upstream reset every character's talents at each level-up below 15 (a
retail rule; Classic talents start at 10). `Player::InitTalentForLevel` in
the core now resets below 15 only when the active talents spend more points
than the character owns, as after lowering its level.

### Starting bags (004)

Every new character gets four of item 277845, A Reasonably Large Bag.

## Configuration

`tools/apply_config.py` writes `server/etc/*.conf` from the stock `.dist`
files and its `SETTINGS`, with the password from `.db_pass`. `--check`
reports whether they are current. Run it after changing a setting or after a
build installs new `.dist` files.
