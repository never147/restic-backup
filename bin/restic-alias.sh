#!/usr/bin/env bash

BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/.. && pwd -P)"

. "$BASE/etc/restic.conf.sh"

command=$1
shift

restic -r "$RESTIC_BACKUP_DEST" "$command" \
    --password-file="$HOME/.restic_pass" \
    "$@"
