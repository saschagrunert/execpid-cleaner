#!/usr/bin/env bash
set -euo pipefail

while true; do
    printf "%s Running cleanup:\n" "$(date)"
    set -x
    find /run/crio/exec-pid-dir -type f -mmin +15 -exec rm -f {} \;
    sleep 15m
    set +x
done
