#!/bin/bash

# This script adds a ssh key to root and disable ssh with password
set -e

# Variables
SSH_PUBLIC_KEY="ssh-ed25519 aaaa some@gmail.com"

# ---- Set user on Linux

# Add ssh public key
mkdir -p /root/.ssh
echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

cat > /etc/ssh/sshd_config.d/hardening.conf <<EOF
PermitRootLogin prohibit-password
EOF

sshd -t && systemctl restart ssh