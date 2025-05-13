#!/usr/bin/env bash

set -exu -o pipefail

. ~/etc/restic.conf.sh

# Fail fast
[ -w "$RESTORE_BASE" ]

: "${SNAPSHOT:=latest}"

restore_dir="$RESTORE_BASE/$RESTIC_BACKUP_DEST/$SNAPSHOT"
mkdir -p "$restore_dir"
restore_point="$restore_dir/restore"

echo "Attempting to restore snapshot: $SNAPSHOT" >&2
restic_cmd restore \
  --verify \
  --target "$restore_point" \
  --verbose \
  "$SNAPSHOT" \
  "$@" \
  | tee "$restore_dir/restore-$(date +"%Y%m%d%M%H%S").log"

echo "Restore succeeded"
