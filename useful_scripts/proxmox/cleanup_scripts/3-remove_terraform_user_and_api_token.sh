#!/bin/bash

# This script removes a role, group, user and api token added for terraform
set -e

# Variables
USERNAME="terraform"
GROUPNAME="terraformGroup"
ROLENAME="terraformRole"
APITOKENNAME="terraformToken"
REALNAME="pve"

# ---- Remove API Token

pveum user token delete $USERNAME@$REALNAME $APITOKENNAME

# ---- Remove permission

pveum acl delete / --role $ROLENAME --group $GROUPNAME

# ---- Remove User

pveum user delete $USERNAME@$REALNAME

# ---- Remove group

pveum group delete $GROUPNAME

# ---- Remove Role
pveum role delete $ROLENAME
