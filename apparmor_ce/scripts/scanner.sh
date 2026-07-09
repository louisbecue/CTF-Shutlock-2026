#!/bin/bash
set -euo pipefail

SCAN_DIR=/var/scan
LOG=/var/log/scanner.log
INTERVAL=30

log() {
    printf "[%s] %s\n" "$(date --iso-8601=seconds)" "$*" >> "$LOG"
}

mkdir -p "$SCAN_DIR"
log "Scanner demarre (PID=$$, profil AppArmor=scanner)"

while true; do
    for binary in "$SCAN_DIR"/*; do
        [ -f "$binary" ]  || continue
        [ -x "$binary" ]  || continue
        [[ "$binary" == *.txt ]] && continue

        name=$(basename "$binary")
        log "Execution de : $name (sous profil AppArmor: var_scan_binary)"

        timeout 10 "$binary" >> "$LOG" 2>&1 || true

        rm -f "$binary"
        log "Nettoyage de : $name"
    done

    sleep "$INTERVAL"
done
