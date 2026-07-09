#!/bin/bash
set -euo pipefail

DONE_MARKER=/etc/apparmor-firstboot-done

if [ -f "$DONE_MARKER" ]; then
    echo "Deja execute : skip."
    exit 0
fi

if ! command -v apparmor_parser &>/dev/null; then
    echo "ERREUR : apparmor_parser introuvable. AppArmor non installe."
    exit 1
fi

if ! aa-status --enabled 2>/dev/null; then
    echo "AVERTISSEMENT : AppArmor non actif dans le kernel. Les profils seront charges mais inactifs."
fi

echo "Chargement des profils AppArmor..."

if [ -f /etc/apparmor.d/usr.local.sbin.scanner ]; then
    apparmor_parser -r -W /etc/apparmor.d/usr.local.sbin.scanner
    echo "Profil scanner charge."
else
    echo "ERREUR : profil scanner introuvable."
    exit 1
fi

if [ -f /etc/apparmor.d/home.player.bash ]; then
    apparmor_parser -r -W /etc/apparmor.d/home.player.bash
    echo "Profil player charge."
else
    echo "ERREUR : profil player introuvable."
    exit 1
fi

echo "Profils AppArmor actifs :"
aa-status --profiled 2>/dev/null || apparmor_parser -L /etc/apparmor.d/ 2>/dev/null || true

touch "$DONE_MARKER"
echo "Initialisation AppArmor terminee."
