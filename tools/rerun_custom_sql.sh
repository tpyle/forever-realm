#!/bin/bash
# Re-runs our custom-sql files on auth and world, to put back what upstream's files overwrote. Run with worldserver stopped,
# after an upstream merge has been through one worldserver start (see README, "Upstream merges").
# Skipped: 005/006 (would undo the NPC models set in game), 012 (not idempotent), 064 (characters, one-off). Of the
# hotfixes files only 059 (Trade Goods stack to 999) is re-run: upstream files replace whole item_sparse records. Prints
# the tables that changed: those are the ones upstream had overwritten.
#
#   tools/rerun_custom_sql.sh [suffix]     suffix "_merge" runs it on the scratch copies
set -euo pipefail
SUFFIX="${1:-}"
ROOT=/opt/wow/forever
export MYSQL_PWD="$(cat $ROOT/.db_pass)"
M="mysql -h127.0.0.1 -utrinity"
TMP=$(mktemp -d); trap 'rm -rf $TMP' EXIT

checksums() {
  for db in auth world; do
    for t in $($M -N $db$SUFFIX -e "show full tables where Table_type='BASE TABLE'" | awk '{print $1}' | grep -v '^updates'); do
      $M -N -e "checksum table $db$SUFFIX.\`$t\`"
    done
  done
}

checksums > $TMP/before
for db in auth world; do
  for f in $ROOT/custom-sql/0*.sql; do
    case $f in *rollback*|*/005_*|*/006_*|*/012_*|*/059_*|*/064_*) continue;; esac
    grep -qiE "apply to the \`?$db\`? database" $f || continue
    if ! sed -E "s/(^|[^a-z_])(auth|world|characters|hotfixes)\.([a-z_])/\1\2${SUFFIX}.\3/g" $f | $M $db$SUFFIX; then
      echo "FAILED: $(basename $f)"; exit 1
    fi
  done
done
stacks() { $M -N hotfixes$SUFFIX -e "select count(*) from item_sparse where Stackable = 999"; }
before=$(stacks)
sed -E "s/(^|[^a-z_])(auth|world|characters|hotfixes)\.([a-z_])/\1\2${SUFFIX}.\3/g" $ROOT/custom-sql/059_reagent_stacks_999.sql |
  $M hotfixes$SUFFIX || { echo "FAILED: 059_reagent_stacks_999.sql"; exit 1; }
checksums > $TMP/after
echo "059: $((  $(stacks) - before )) items back at a stack of 999"
echo "changed:"; diff $TMP/before $TMP/after | sed -n 's/^> \([^\t]*\).*/  \1/p'
