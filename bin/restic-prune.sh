#!/usr/bin/env bash

BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/.. && pwd -P)"

. "$BASE/etc/restic.conf.sh"

restic forget \
    -r "$RESTIC_BACKUP_DEST" \
    --password-file=/home/"$USER"/.restic_pass \
    --keep-daily 7 \
    --keep-weekly 5 \
    --keep-monthly 3 \
&& restic prune \
    -r "$RESTIC_BACKUP_DEST" \
    --password-file=/home/"$USER"/.restic_pass
