#!/bin/bash

# This script remove the first LXC created on Proxmox
# The LXC used to manage and access to every other VM or LXC
set -e

# Variables
VMID=100

# stop LXC if running
if pct status $VMID | grep -q running; then
  echo "Stopping LXC $VMID."
  pct stop $VMID
fi

# remove LXC and everything associated
echo "Deleting LXC $VMID."
pct destroy $VMID --purge

echo "LXC $VMID removed."