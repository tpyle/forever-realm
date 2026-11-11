#!/bin/bash
# Applies the upstream SQL files the databases have not had yet, in the order the worldserver's updater uses (file name
# order over sql/updates/<db> and sql/custom/<db>), and records each in <db>.updates so the updater skips it. Run with
# worldserver stopped. Our own files that upstream overwrites are re-applied after it:
#   hotfixes: 065 first (our hotfix_data ids out of upstream's range)
#   world:    052 (Sky Elf trainer faction), 056 (after 052: its NPCs' ContentTuning), 057 (quest ContentTuning),
#             061 (Pick Lock at blacksmith trainers) after
# A file that fails stops the run; fix it and run again (applied files are recorded and skipped).
# The worldserver's updater still re-runs, at its next start, every upstream custom file whose content changed since it was
# applied, and every custom file after it (on 0.1.34: about 500 auth and world files). So after this, start the worldserver
# once, stop it, run tools/rerun_custom_sql.sh, start again (README, "Upstream merges").
#
#   tools/apply_upstream_sql.sh [suffix]     suffix "_merge" runs it on the scratch copies (auth_merge, world_merge, ...)
set -euo pipefail
SUFFIX="${1:-}"
ROOT=/opt/wow/forever
T=$ROOT/TrinityCore
export MYSQL_PWD="$(cat $ROOT/.db_pass)"
M="mysql -h127.0.0.1 -utrinity"

# file content with database-qualified names pointed at the target databases (two upstream files write world.smart_scripts)
qualified() { sed -E "s/(^|[^a-z_])(auth|world|characters|hotfixes)\.([a-z_])/\1\2${SUFFIX}.\3/g" "$1"; }

run_ours() { # db file
  echo "  ours: $(basename $2)"
  qualified "$2" | $M "$1"
}

for db in auth characters hotfixes world; do
  target="$db$SUFFIX"
  echo "== $target"
  [ $db = hotfixes ] && run_ours $target $ROOT/custom-sql/065_hotfix_ids_own_range.sql

  applied=$($M -N $target -e "select name from updates")
  count=0
  for path in $( (ls $T/sql/updates/$db/*.sql $T/sql/custom/$db/*.sql 2>/dev/null || true) | awk -F/ '{print $NF"\t"$0}' | LC_ALL=C sort | cut -f2); do
    name=$(basename "$path")
    grep -qxF "$name" <<<"$applied" && continue
    if [ "$name" = 2026_10_31_00_hotfixes_spell_duration_per_level.sql ] &&
       [ "$($M -N $target -e "select count(*) from information_schema.columns where table_schema='$target' and table_name='spell_duration' and column_name='DurationPerLevel'")" = 1 ]; then
      echo "  skip (column already there): $name"
    else
      start=$(date +%s%N)
      if ! qualified "$path" | $M $target; then echo "FAILED: $name"; exit 1; fi
    fi
    hash=$(sha1sum "$path" | cut -d' ' -f1 | tr a-f A-F)
    $M $target -e "INSERT INTO updates (name, hash, state, timestamp, speed) VALUES ('$name', '$hash', 'RELEASED', NOW(), 0)"
    count=$((count + 1))
  done
  echo "  $count upstream files"

  if [ $db = world ]; then
    for f in 052_skyelf_trainers 056_custom_npc_content_tuning 057_worldscale_quest_content_tuning 061_pick_lock_blacksmith_trainers; do
      run_ours $target $ROOT/custom-sql/$f.sql
    done
  fi
done
echo done
