#!/usr/bin/env bash

BASE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/.. && pwd -P)"

. "$BASE/etc/restic.conf.sh"

restic_cmd backup \
    --exclude-file="$HOME/etc/restic_glob_exclude.txt" \
    --exclude-caches \
    "$@" \
    "$HOME"
