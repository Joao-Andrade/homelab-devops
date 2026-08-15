#!/bin/bash

# This script adds a group and a user to Proxmox
# It also allows to access Proxmox via SSH
set -e

# Variables
USERNAME="aaaa"
GROUPNAME="administrators"
PASSWORD="aaa"
REALMNAME="pve"
EMAIL="EMAIL_ADDRESS"
COMMENT="Proxmox Administrator user"
FIRSTNAME="aaa"
LASTNAME="aaa"

echo "Creating group $GROUPNAME"
pveum group add $GROUPNAME

echo "Creating user $USERNAME@$REALMNAME"
pveum user add $USERNAME@$REALMNAME --password $PASSWORD --comment "$COMMENT" --email $EMAIL --firstname $FIRSTNAME --lastname $LASTNAME --groups $GROUPNAME

echo "Setting administrator permissions for group $GROUPNAME"
pveum acl modify / --role Administrator --group $GROUPNAME