# AGENTS.md

A WoW Forever (Classic 1.60) realm on the `forever` branch of
advocaite/TrinityCore, run alongside the WotLK server in `/opt/wow/classic`.
`README.md` records what was changed and why; read the relevant section
before touching it. This file is the short list of rules and traps.

## The tree is two repositories

- This repository (`tpyle/forever-realm`) holds `custom-sql/`,
  `client-addon/`, `tools/` and the docs.
- `TrinityCore/` is the core (`tpyle/TrinityCore`, branch `trunk`, which is
  upstream `forever` plus our commits). `origin` is the fork and `upstream`
  is advocaite. Commit C++ changes there.
- Gitignored and only on disk: `server/` (binaries, generated config, client
  data, logs), `build/`, `.db_pass`.

## Running

- systemd units `forever-world` and `forever-bnet` (copies in
  `tools/systemd/`). Never start the binaries by hand.
- `forever-world` allows only 3 starts in 30 minutes. If systemd refuses a
  restart, `sudo systemctl reset-failed forever-world` and start it.
- Ask before restarting while a player is online. Run `saveall` first.
- World console: `timeout 5 sh -c "echo '<command>' > /run/forever-world/console"`;
  the output is in `journalctl -u forever-world`.
- MySQL 8.4 on `127.0.0.1`, user `trinity`, password in `.db_pass`
  (`export MYSQL_PWD="$(cat .db_pass)"`, never print it). Databases `auth`,
  `world`, `characters`, `hotfixes`.
- `server/logs/DBErrors.log` (about 150 MB) is rewritten at every start;
  most of it is stock data noise.

## Building

- `cd build && CC=gcc-14 CXX=g++-14 cmake . && make -j48 worldserver`. The
  binary lands in `build/bin/Release/bin/worldserver`; keep the previous
  `server/bin/worldserver` as a backup, stop the server, copy, start.
- Scripts are static (`SCRIPTS=static`): a new script needs a rebuild, and a
  registration in `src/server/scripts/Custom/custom_script_loader.cpp`.

## Configuration and SQL

- `server/etc/*.conf` are generated. Change settings in
  `tools/apply_config.py` and run it; direct edits are lost on the next run.
- `Realm.AlsoAcceptBuilds` must be set in both files when the realm's build
  (auth.realmlist.gamebuild) differs from the client's. Missing it in
  worldserver.conf made character creation hang on the finish button.
- Every change to the databases is a numbered file in `custom-sql/` with a
  `.rollback.sql` beside it. Each says which database it applies to and
  whether it needs a restart (most do: the server loads these tables at
  startup).
- What the client allows (race/class combinations, starting gear) comes from
  its DB2 files, overridden by rows in `hotfixes` plus a `hotfix_data` entry.
- A scripted gossip NPC still needs a `creature_template_gossip` row, or the
  server hides its gossip flag and it cannot be clicked.
- `playercreateinfo_spell_custom` only applies with `PlayerStart.AllSpells = 1`.
- Custom creature entries start at 8103001 and spawn guids at 26300001.
  Check the highest used before adding more.
