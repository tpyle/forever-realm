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

Known gaps: paladin chargers and priest racial spells stay
race-locked.

### Trainers for the new classes (005-007, 014-020)

Shaman and paladin trainers in every capital that lacked them, copied from
stock trainers and given random appearances: Rowan Stormcaller (Stormwind),
Korrin Stonecaller (Ironforge), Aerin Windcaller and Selen Dawnward
(Darnassus), Tahna Sunhoof (Thunder Bluff), Morwen Gravecaller and Alric
Ashward (Undercity), Durga Lightsworn (Orgrimmar, Valley of Honor) and
Korgath the Redeemed (Valley of Trials, by the orc and troll start).
Shaman trainers use trainer list 10 and menu 5123, paladin ones list 29 and
menu 4663.

Northshire (027-031), where only humans start: Corwin Oakheart (druid) and
Brannoc Stormward (shaman) by the stables outside the abbey, with the
starting-zone trainer lists (spells up to level 6: druid list 1233 and menu
4688, shaman list 11 and menu 4652), and class quests from Marshal McBride
after Kobold Camp Cleanup, like the other classes' letters (no letter item):
A Druid's Summons (9100301) and A Shaman's Summons (9100302), level 1, with
QuestV2 hotfix rows (bits 72950-72951).

Coldridge Valley (033-035), where dwarves and gnomes start: Durgan
Mossbeard (druid, a copy of Corwin with a dwarf look and the Ironforge
faction) inside Anvilmar. Sten Stoutarm's class letters (after Dwarven
Outfitters) were runes for dwarves and memorandums for gnomes, each race
missing some classes; the existing letters are now open to both races
(Consecrated, Etched and Archaic Rune for gnomes, Glyphic and Tainted
Memorandum for dwarves), and A Druid's Summons (9100303, QuestV2 bit 72952)
sends druids of both to Durgan.

Shadowglen (036-038): Thalric Dawnleaf (paladin), Ilyran Stormbough
(shaman, at the foot of Aldrassil), Sylwen Starweaver (mage) and Naeryth
Duskshade (warlock), with class quests from Conservator Ilthalaine after The
Balance of Nature. Deathknell (041-044): Edric Thornwood (hunter, upstairs
with the warrior trainer), Mordecai Vale (shaman, by the graveyard) and
Agatha Fenwick (druid, outside the church), with quests from Shadow Priest
Sarvis after The Mindless Ones. Camp Narache (045-048): Ahrok Dawnhoof
(paladin), Kesh Swiftstride (rogue), Yanna Brightmane (priest, east of the
camp), Tarhi Starhorn (mage, by the kodo skeleton to the south) and Grath
Ashmane (warlock, behind the graveyard), with quests from Grull Hawkwind
after The Hunt Begins. Valley of Trials (049-051): Thrag Earthroot (druid,
just outside the camp), and quests from Gornek after Cutting Teeth for orc
priests (to Ken'jai) and orc and troll paladins (to Korgath) and druids.
Orcs and trolls get separate copies, so each gets its race's reputation
(Orgrimmar, Darkspear), like the stock parchments and tablets. Korgath now
has the starting paladin list (28) instead of the capital one.

Sky Elf start (052-054): both Sky Elf races (95 Alliance, 96 Horde) start
in Thendal Grove (map 2991), whose NPCs are mostly neutral (faction 35).
Saraan Brightgale (paladin), Liaara Moonbreeze (priest) and Vexaan Duskgale
(warlock) are neutral too, and Rorian the Dayseeker offers their class
quests, and a mage one for Dorii Brightwhisper, to both races after Harmony
in Balance (level 2, Skyborne reputation, like the stock ones). No stock
priest or warlock greeting is readable by both factions, so those two have
their own menus (8103028-8103029: a universal stock text plus copies of
the stock options and conditions). The shaman trainers (Windshapers, 3599)
and Dorii (High Order, 3600) were hostile to the other faction and are now
neutral. The two later Sky Elf hubs still have no paladin, priest or
warlock trainers.

How these are made, for the remaining starting zones:

- Each trainer is a copy of a starting-zone trainer of its class (its
  trainer list teaches spells up to level 6, and its menu has the class
  greetings), with an appearance borrowed from a local NPC, the zone's
  faction, and the spawn settings of a trainer there.
- Greetings keep the language they were written in: a menu copied from an
  Alliance trainer may be in Common, which Horde characters cannot read
  (048). Check `broadcast_text.LanguageID` (0 universal, 1 Orcish,
  7 Common) and avoid texts naming another race's leaders or places.
- Each class quest is a copy of A Druid's Summons (9100301, level 1 with
  the Classic level and money rows, no letter item), with the zone's
  faction as its reputation reward (039; not Stormwind) and no portrait
  (040: a portrait showed as a grey box), plus a QuestV2 hotfix row.

Class trainers train only their own class (032, core). Upstream offered
every class trainer's training window to everyone. `Creature::CanTrainPlayerClass`
(from `creature_template.trainer_class`) now hides the training option and
refuses the trainer list and purchases for other classes, who see only the
greeting. Trainers with no class (professions, weapon masters) are
unaffected. 032 sets `trainer_class` on 24 Classic 1.60 class trainers
that had none (Tordrin Sternblade, Teo Hammerstorm, the Sky Elf trainers
and others), which also lets them reset talents for their class.

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

### Bonus stats (026, `cs_bonusstats`)

    .bonusstats show  [player]
    .bonusstats grant <stat> <amount> [player]
    .bonusstats take  <stat> <amount> [player]
    .bonusstats set   <stat> <amount> [player]

Stats: strength, agility, stamina, intellect, spirit, hit, crit, haste,
expertise, dodge, parry, block, attackpower, spellpower, armor, health, mana
(at most 100000 each). Bonuses are rows in `characters.character_bonus_stat`,
applied at every login the way gear applies its stats; primary stats, armor,
health and mana as base values (white, scaled by percentage buffs). Level-ups
never reset these modifiers. Offline characters can be changed; it applies at
their next login. Ratings convert at the same rate at every level in this
client: 10 hit = 1% hit, 14 crit = 1% crit, 10 haste = 1% haste.

Upstream's fix for stats stacking on level-up set a stat's whole base value
to the new level's base stat, which dropped these bonuses until a relog.
`Unit::SetCreateStat` now tracks the create stat separately and replaces
only that part.

### World scaling (055-056, core `WorldScale.h`)

A port of the WotLK realm's AzerothCore mod-worldscale: a creature below a
player's level fights, shows and rewards as though it were the player's
level, for each player separately. Scaling is up only, applies in dungeons
and raids (never battlegrounds or arenas), includes elites, and leaves boss
mobs alone. Settings are the `WorldScale.*` keys in `tools/apply_config.py`.

The client does the per-player part itself through ContentTuning. 055 adds
hotfix rows 8100001-8100059 (row 8100000 + N covers levels N-60), and a
vanilla creature at level N that may scale gets row 8100000 + N when it
spawns. The client then shows each player the creature at their own level
(clamped to the row) and scales the health it shows by the same vanilla
class/level table (`creature_classic_classlevelstats`) the server uses.
Unlike retail, the creature keeps its own level and stats on the server;
its per-target level (`Creature::GetLevelForTarget`, players and their pets
only) drives the hit tables and the damage, health and armour multipliers.
056 puts the custom NPCs (8103001-8103029) on the 1-60 row, so trainers
show each player their own level.

- Damage a player deals is divided by the health multiplier; the fraction
  of a health point left over carries to the next hit, so the bar does not
  drift.
- Combat log overkill is worked out in the player's (scaled) points, or the
  client would empty the bar on hits the creature survives.
- No `SMSG_ATTACK_SWING_LANDED_LOG` for hits on a scaled creature: the
  client put its victim health (the real, unscaled value) on the health bar
  every so often. The combat log is complete without it.
- Kill experience: half way (`KillXPFraction`) from what the creature pays
  a player of its own level to what a creature of the player's level pays.
  A level 1 creature to a level 5 player: 50 -> 70, pays 60.
- A scaled creature aggroes as if 5 levels below the player
  (`Aggro.LevelsBelow`), and skinning uses its real level.

Quests work the same way (057): each vanilla quest of level 1-59 with a
minimum level is on the 055 row of its level, so the client shows it at
the player's level, never below its own, and low quests are not trivial
(quest giver status uses the shown level). The server keeps the quest's
fixed level, and a quest below the player pays half way
(`QuestXPFraction`) from its experience at its own level to a quest of the
player's level: a level 4 quest (35) to a level 7 player (65) pays 50.
The turn-in window shows what is paid; the quest log is the client's own
figure from the row, the full at-level amount (65), and cannot show the
blend. Money and items are unchanged. Clients keep quest details in their
`Cache` folder; delete it once after changing quest data. Left out: 117
Thunderbrew and 7838 Arena Grandmaster (no minimum level, which the row
would set to the quest level).

In a group, kill experience is not split (`GroupXPSplit` 0, as on the
WotLK realm): each member earns what they would have alone, so grouping
costs nothing. Nothing still goes to a member for whom the creature is
gray. Summons of a scaled creature use the retail multipliers.

### Core fixes for the Classic client

- Transmog: only soulbound items were collected, and most white and grey
  gear has no binding, so vendor and looted gear never counted.
  `CollectionMgr::AddItemAppearance` collects unbound items when obtained.
  Bind-on-equip gear is still collected only once it binds, or when it is
  sold to a vendor or disenchanted (`AddItemAppearanceOnDisposal`).
- Keybinds: the client uploads account data (keybinds, layout) at logout,
  but at login it keeps its own local copy when the server's time equals
  it, and that copy is stale, so keybinds reverted to defaults.
  `WorldSession::SendAccountDataTimes` presents stored data as current, so
  the client always loads it from the server. (Debug logging showed the
  client requests and applies it once the server's copy is newer.) Once
  since then (2026-11-08), the client uploaded an old copy of the account
  keybinds at a login and replaced the good one; a server restart while in
  game and a new character's first login did not reproduce it. If it
  recurs, `server set loglevel l root 2` logs every account data request
  and upload to `server/logs/Server.log` (`5` restores the level).

### Trade Goods stack to 999 (059, `tools/reagent_stacks.py`)

Every Trade Goods item (class 7) that stacks, to fewer than 999, stacks
to 999: 462 items (cloth, leather, herbs, ore, bars, stone, gems, meat,
dusts, thread, vials and the like). Single items (rods, Flint and Tinder,
clams, supply crates) and the few 1000+ stacks are unchanged. Client and
server both take stack sizes from ItemSparse, so each is a hotfix row
with the whole record: 460 new `item_sparse` rows read from the client's
`ItemSparse.db2` (`tools/db2read.py`, a small WDC5 reader checked against
the existing hotfix rows), and 2 existing rows changed. The script writes
059 and its rollback; rerun it if a client update changes ItemSparse.

### Quest log of 40

The Forever client's quest log counts to 40 (12/40), but the core kept
retail's 35 (`MAX_QUEST_LOG_SIZE` in `QuestDef.h`), so quests 36-40 were
refused as "quest log full". It is 40 now. The update fields have room
for 175.

### Pick Lock at blacksmiths (060-062)

Any class with Blacksmithing can learn Pick Lock (1804) at level 16 from
every Blacksmithing trainer (061: 1800 copper, Blacksmithing 1), and needs
Thieves' Tools (5060) to use it. Lockpicking (skill 633) works as in vanilla.
Learning Pick Lock starts it at 1, it caps at 5 per level, and picking a lock
can raise it, with the same chance as Herbalism. Locks check it.

- 060 (hotfixes): a SkillRaceClassInfo row (2616) for Lockpicking for every
  class and race; the stock row (601) is rogue-only.
- 062 (hotfixes): a SkillLineAbility copy (60021) of Pick Lock's stock row
  (8439) for the non-rogue classes. Without it the server sent Pick Lock
  as available but the client left it out of the trainer list, the same
  as the weapon spells in 022.
- Core: `SkillByLockType` had no skill for `LOCKTYPE_LOCKPICKING`, so
  every player, rogues included, picked with skill 0 and any lock with a
  skill requirement failed. It maps to `SKILL_LOCKPICKING` now.
  `Player::AddSpell` starts the skill when Pick Lock is learned, since the
  ability is trained rather than automatic. `UpdateGatherSkill` gains it
  like Herbalism.

### Starting bags (004)

Every new character gets four of item 277845, A Reasonably Large Bag.

## Configuration

`tools/apply_config.py` writes `server/etc/*.conf` from the stock `.dist`
files and its `SETTINGS`, with the password from `.db_pass`. `--check`
reports whether they are current. Run it after changing a setting or after a
build installs new `.dist` files.
