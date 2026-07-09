#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq && apt-get install -y \
    openssh-server \
    openssh-client \
    gcc \
    libc6-dev \
    make \
    apparmor \
    apparmor-utils \
    apparmor-profiles \
    libapparmor-dev \
    libpam-apparmor \
    nano \
    vim \
    procps \
    util-linux \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

mkdir -p /secure_data
printf "Voici la liste confidentielle de nos agents:\n SHLK{FAKE_FLAG}\n\n" \
       "==============================\n\n" \
       "Here is our confidential list of agents:\n SHLK{FAKE_FLAG}\n\n" \
       > /secure_data/agents.txt
chown root:root /secure_data/agents.txt
chmod 750 /secure_data
chmod 640 /secure_data/agents.txt

useradd -m -d /home/player -s /bin/bash player
echo "player:player" | chpasswd

mkdir -p /var/scan
chown root:root /var/scan
chmod 1777 /var/scan

cat > /var/scan/README.txt << 'EOF'
Scanner de securite interne du Listembourg
Tout binaire executable depose ici sera analyse automatiquement toutes les 30 secondes.
EOF
chmod 644 /var/scan/README.txt

cp /tmp/scanner.sh /usr/local/sbin/scanner
chmod 755 /usr/local/sbin/scanner
chown root:root /usr/local/sbin/scanner

mkdir -p /etc/apparmor.d
cp /tmp/apparmor/usr.local.sbin.scanner /etc/apparmor.d/usr.local.sbin.scanner
cp /tmp/apparmor/home.player.bash       /etc/apparmor.d/home.player.bash
chmod 644 /etc/apparmor.d/usr.local.sbin.scanner
chmod 644 /etc/apparmor.d/home.player.bash

mkdir -p /etc/security
cat > /etc/security/apparmor.conf << 'PAM_CONF'
player player_shell
PAM_CONF
chmod 644 /etc/security/apparmor.conf

PAM_SSHD=/etc/pam.d/sshd
if ! grep -q "pam_apparmor" "$PAM_SSHD" 2>/dev/null; then
    echo "session optional pam_apparmor.so order=user,@default,default" >> "$PAM_SSHD"
fi

mkdir -p /run/sshd /var/run/sshd
find /etc/ssh/sshd_config.d/ -type f -exec sed -i '/PasswordAuthentication/d' {} + 2>/dev/null || true
sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config 2>/dev/null || true
sed -i '/PermitRootLogin/d' /etc/ssh/sshd_config 2>/dev/null || true

cat >> /etc/ssh/sshd_config << 'SSHEOF'
PasswordAuthentication yes
PermitRootLogin no
SSHEOF

cat > /etc/motd << 'MOTD'

  ╔══════════════════════════════════════════════════════════════════╗
  ║        SYSTEME INTERNE DU LISTENBOURG - ACCES RESTREINT          ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

echo "Installation terminee (build phase)."
