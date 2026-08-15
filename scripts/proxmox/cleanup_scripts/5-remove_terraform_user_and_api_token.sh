#!/bin/bash

# This script removes a role, group, user and api token added for terraform
set -e

# Variables
USERNAME="terraform"
GROUPNAME="terraformGroup"
ROLENAME="terraformRole"
APITOKENNAME="terraformToken"
REALMNAME="pve"

# ---- Remove permission

echo "Removing permission for api token $APITOKENNAME"
pveum acl delete / --role $ROLENAME --token $USERNAME@$REALMNAME!$APITOKENNAME

# ---- Remove API Token

echo "Removing api token $APITOKENNAME"
pveum user token delete $USERNAME@$REALMNAME $APITOKENNAME

# ---- Remove permission

echo "Removing permission for role $ROLENAME and group $GROUPNAME"
pveum acl delete / --role $ROLENAME --group $GROUPNAME

# ---- Remove User

echo "Removing user $USERNAME@$REALMNAME"
pveum user delete $USERNAME@$REALMNAME

# ---- Remove group

echo "Removing group $GROUPNAME"
pveum group delete $GROUPNAME

# ---- Remove Role

echo "Removing role $ROLENAME"
pveum role delete $ROLENAME
