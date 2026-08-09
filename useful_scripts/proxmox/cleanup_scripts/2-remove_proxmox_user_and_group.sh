#!/bin/bash

# This script removes a group and a user from Proxmox
set -e

# Variables
USERNAME="user_a"
GROUPNAME="administrators"
REALM="pve"

# ---- Remove permissions
pveum acl delete / --role Administrator --group $GROUPNAME

# ---- Delete User
pveum user delete $USERNAME@$REALM

# ---- Delete group
pveum group delete $GROUPNAME