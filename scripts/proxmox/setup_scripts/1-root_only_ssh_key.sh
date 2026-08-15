#!/bin/bash

# This script adds a ssh key to root and disable ssh with password
set -e

# Variables
SSH_PUBLIC_KEY="ssh-ed25519 aaaa some@gmail.com"

echo "Adding ssh public key to root authorized keys"

mkdir -p /root/.ssh
echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

echo "Updating hardening config file to disable root password login"

cat > /etc/ssh/sshd_config.d/hardening.conf <<EOF
PermitRootLogin prohibit-password
EOF

echo "Restarting ssh daemon"

sshd -t && systemctl restart ssh