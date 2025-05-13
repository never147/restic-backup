#!/usr/bin/env bash

: "${USER:=$LOGNAME}"
: "${BACKUP_HOST?"Please set BACKUP_HOST to the hostname of the backup server"}"
: "${SSH_KEY:="$HOME/.ssh/id_rsa.$USER"}"
: "${RESTIC_BACKUP_DEST:="rclone:${BACKUP_HOST}:$(hostname)"}"
: "${RESTORE_BASE="/var/restore/$USER"}"

export RESTIC_BACKUP_DEST RESTORE_BASE

if [ -z "${SSH_AUTH_SOCK:-}" ] ;then
  eval "$(ssh-agent)" >/dev/null
  ssh-add "$SSH_KEY"
fi
ssh-add -l

restic_cmd() {
  restic \
    -r "$RESTIC_BACKUP_DEST" \
    --password-file="$HOME/.restic_pass" \
    "$@"
}
