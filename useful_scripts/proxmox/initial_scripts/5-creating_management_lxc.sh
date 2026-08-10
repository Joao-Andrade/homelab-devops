#!/bin/bash

# This script creates the first LXC on Proxmox
# This uses a Debian template and will be used
# to manage and access to every other VM or LXC
set -e

# Variables
VMID=100
HOSTNAME="homelab-mn"
TEMPLATE="local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
STORAGE="local-lvm"
DISK_SIZE="20"
MEMORY="512"
CORES="1"
BRIDGE="vmbr0"
MAC="02:00:00:00:01:a1"
IP="192.168.1.80/24"
GATEWAY="192.168.1.1"
PATH_TO_SSH_PUBLIC_KEY="<path-to-ssh-public-key>"

echo "Creating LXC."
pct create $VMID $TEMPLATE \
  --hostname $HOSTNAME \
  --storage $STORAGE \
  --rootfs $STORAGE:$DISK_SIZE \
  --memory $MEMORY \
  --cores $CORES \
  --net0 name=eth0,bridge=$BRIDGE,hwaddr=$MAC,ip=$IP,gw=$GATEWAY \
  --unprivileged 1 \
  --features nesting=0 \
  --onboot 1 \
  --ssh-public-keys $PATH_TO_SSH_PUBLIC_KEY

echo "Starting LXC."
pct start $VMID