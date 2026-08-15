#!/bin/bash

# This script adds a role, group, user and api token to be used by terraform
set -e

# Variables
USERNAME="terraform"
GROUPNAME="terraformGroup"
ROLENAME="terraformRole"
APITOKENNAME="terraformToken"
REALMNAME="pve"
COMMENT="Terraform service account"
FIRSTNAME="Terraform"
LASTNAME="Account"
PREVILEDGES="Datastore.Allocate \
Datastore.AllocateSpace \
Datastore.Audit \
Pool.Allocate \
SDN.Use \
Sys.Audit \
Sys.Console \
Sys.Modify \
Sys.PowerMgmt \
VM.Allocate \
VM.Audit \
VM.Clone \
VM.Config.CDROM \
VM.Config.Cloudinit \
VM.Config.CPU \
VM.Config.Disk \
VM.Config.HWType \
VM.Config.Memory \
VM.Config.Network \
VM.Config.Options \
VM.Console \
VM.Migrate \
VM.PowerMgmt"

echo "Creating role $ROLENAME"
pveum role add $ROLENAME --privs "$PREVILEDGES"

echo "Creating group $GROUPNAME"
pveum group add $GROUPNAME

echo "Creating user $USERNAME@$REALMNAME"
pveum user add $USERNAME@$REALMNAME --comment "$COMMENT" --firstname $FIRSTNAME --lastname $LASTNAME --groups $GROUPNAME

echo "Setting role permissions $ROLENAME for group $GROUPNAME"
pveum acl modify / --role $ROLENAME --group $GROUPNAME

echo "Creating api token $APITOKENNAME for user $USERNAME@$REALMNAME"
pveum user token add $USERNAME@$REALMNAME $APITOKENNAME

echo "Setting role permissions $ROLENAME for api token $APITOKENNAME"
pveum acl modify / --role $ROLENAME --token $USERNAME@$REALMNAME!$APITOKENNAME
