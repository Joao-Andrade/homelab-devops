#!/bin/bash

# This script removes a ssh key to root and the entry in sshd_config to disable ssh with password
set -e

# Variables
SSH_PUBLIC_KEY="ssh-ed25519 aaaa some@gmail.com"

# remove hardening.conf
sed -i 's/PermitRootLogin prohibit-password//g' /etc/ssh/sshd_config.d/hardening.conf

# Remove ssh public key
sed -i "/$SSH_PUBLIC_KEY/d" /root/.ssh/authorized_keys

# Restart ssh
systemctl restart ssh
