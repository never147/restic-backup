#!/usr/bin/env bash

set -exu -o pipefail

. etc/restic.conf.sh

# Fail fast
[ -w "$RESTORE_BASE" ]

echo "Looking for snapshots" >&2
snapshots=$(restic_cmd snapshots --json)
num=$(jq length <<<"$snapshots")
echo "Found $num snapshots" >&2
random_snapshot_num=$(( RANDOM % num ))
snapshot=$(jq -r ".[$random_snapshot_num].id" <<<"$snapshots")
[ "$snapshot" != "null" ]

restore_dir="$RESTORE_BASE/$snapshot"
mkdir -p "$restore_dir"
restore_point="$restore_dir/restore"
trap 'rm -rf $restore_dir' EXIT

echo "Attempting to restore snapshot num $(( random_snapshot_num +1 )): $snapshot" >&2
restic_cmd restore \
  --verify \
  --target "$restore_point" \
  --verbose \
  "$snapshot" \
  | tee "$restore_dir/restore-$(date +"%Y%m%d%M%H%S").log"

echo "Testing restore" >&2
[ -d "${restore_point}$HOME/Documents" ]
# FIXME add more tests

echo "Test succeeded"
