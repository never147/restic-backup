#!/usr/bin/env bash

command=$1
shift

. "$HOME/etc/restic.conf.sh"

restic -r "$RESTIC_BACKUP_DEST" "$command" \
    --password-file="$HOME/.restic_pass" \
    "$@"
