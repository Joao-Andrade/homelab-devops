#!/bin/bash

# This script removes a group and a user from Proxmox
set -e

# Variables
USERNAME="aaaa"
GROUPNAME="administrators"
REALMNAME="pve"

# ---- Remove permissions

echo "Removing permissions for role Administrator and group $GROUPNAME"
pveum acl delete / --role Administrator --group $GROUPNAME

# ---- Delete User

echo "Removing user $USERNAME@$REALMNAME"
pveum user delete $USERNAME@$REALMNAME

# ---- Delete group

echo "Removing group $GROUPNAME"
pveum group delete $GROUPNAME