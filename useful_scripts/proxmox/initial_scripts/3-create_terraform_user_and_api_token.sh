#!/bin/bash

# This script adds a role, group, user and api token to be used by terraform
set -e

# Variables
USERNAME="terraform"
GROUPNAME="terraformGroup"
ROLENAME="terraformRole"
APITOKENNAME="terraformToken"
REALNAME="pve"
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

# ---- Create Role
pveum role add $ROLENAME --privs "$PREVILEDGES"

# ---- Create group

pveum group add $GROUPNAME

# ---- Create User

pveum user add $USERNAME@$REALNAME --comment "$COMMENT" --firstname $FIRSTNAME --lastname $LASTNAME --groups $GROUPNAME

# ---- Set permission

pveum acl modify / --role $ROLENAME --group $GROUPNAME

# ---- Set API Token

pveum user token add $USERNAME@$REALNAME $APITOKENNAME
