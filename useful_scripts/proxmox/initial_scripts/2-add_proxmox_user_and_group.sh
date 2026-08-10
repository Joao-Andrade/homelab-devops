#!/bin/bash

# This script adds a group and a user to Proxmox
# It also allows to access Proxmox via SSH
set -e

# Variables
USERNAME="user_a"
GROUPNAME="administrators"
PASSWORD="somepassword"
REALNAME="pve"
EMAIL="someemail@provider.com"
COMMENT="Proxmox Administrator user"
FIRSTNAME="somefirstname"
LASTNAME="somelastname"

# ---- Create group

pveum group add $GROUPNAME

# ---- Create User

pveum user add $USERNAME@$REALNAME --password $PASSWORD --comment "$COMMENT" --email $EMAIL --firstname $FIRSTNAME --lastname $LASTNAME --groups $GROUPNAME

# ---- Set permission

pveum acl modify / --role Administrator --group $GROUPNAME
