#!/bin/bash

# This script deletes the ISOs and templates on Proxmox
# The ISO is a debian and the templates are debian and alpine
set -e

# Variables
ISO="debian-13.6.0-amd64-netinst.iso"
DEBIAN_TEMPLATE="vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
ALPINE_TEMPLATE="vztmpl/alpine-3.24-default_20260714_amd64.tar.xz"

# ---- Remove templates
echo "Removing Debian template $DEBIAN_TEMPLATE"
pveam remove local:$DEBIAN_TEMPLATE
echo "Removing Alpine template $ALPINE_TEMPLATE"
pveam remove local:$ALPINE_TEMPLATE

# ---- Remove ISO
echo "Removing ISO $ISO_URL"
cd /var/lib/vz/template/iso
rm $ISO

pveam update