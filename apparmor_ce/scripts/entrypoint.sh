#!/bin/bash
set -euo pipefail

echo "Demarrage du conteneur"

if [ -d /sys/module/apparmor ] && [ "$(cat /sys/module/apparmor/parameters/enabled 2>/dev/null)" = "Y" ]; then
    echo "AppArmor detecte et actif - chargement des profils..."

    mount -t securityfs securityfs /sys/kernel/security 2>/dev/null || true

    apparmor_parser -r -W /etc/apparmor.d/usr.local.sbin.scanner && \
        echo "Profil 'scanner' charge." || \
        echo "WARN: echec chargement profil scanner"

    apparmor_parser -r -W /etc/apparmor.d/home.player.bash && \
        echo "Profil 'player_shell' charge." || \
        echo "WARN: echec chargement profil player"

    echo "Profils AppArmor actifs :"
    aa-status --profiled 2>/dev/null || true
else
    echo "WARN: AppArmor non actif dans ce kernel"
    echo "Les profils sont installes mais inactifs - mode TEST UNIX seul."
fi
echo "Demarrage SSH..."
ssh-keygen -A 2>/dev/null || true
mkdir -p /run/sshd
/usr/sbin/sshd -D &
SSH_PID=$!
echo "sshd demarre (PID=$SSH_PID)"

echo "Demarrage du scanner..."
mkdir -p /var/log
touch /var/log/scanner.log
/usr/local/sbin/scanner &
SCANNER_PID=$!
echo "Scanner demarre (PID=$SCANNER_PID)"

echo "Container pret. ssh player@<host> -p <port> (pass: player)"

cleanup() {
    echo "Arret du container..."
    kill $SSH_PID $SCANNER_PID 2>/dev/null || true
    wait $SSH_PID $SCANNER_PID 2>/dev/null || true
    exit 0
}
trap cleanup SIGTERM SIGINT

while true; do
    if ! kill -0 $SSH_PID 2>/dev/null; then
        echo "sshd mort - relance..."
        /usr/sbin/sshd -D &
        SSH_PID=$!
    fi
    if ! kill -0 $SCANNER_PID 2>/dev/null; then
        echo "scanner mort - relance..."
        /usr/local/sbin/scanner &
        SCANNER_PID=$!
    fi
    sleep 10
done
