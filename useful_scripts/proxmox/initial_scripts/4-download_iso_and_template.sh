#!/bin/bash

# This script downloads ISOs and templates to Proxmox
# The ISO is a debian and the templates are debian and alpine
set -e

# Variables
ISO_URL="https://mirrors.up.pt/debian-cd/13.6.0/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso"
DEBIAN_TEMPLATE="debian-13-standard_13.6-1_amd64.tar.zst"
ALPINE_TEMPLATE="alpine-3.24-default_20260714_amd64.tar.xz"

# ---- Download templates
echo "Downloading Debian template $DEBIAN_TEMPLATE"
pveam download local $DEBIAN_TEMPLATE
echo "Downloading Alpine template $ALPINE_TEMPLATE"
pveam download local $ALPINE_TEMPLATE

# ---- Download ISO
echo "Downloading ISO from $ISO_URL"
cd /var/lib/vz/template/iso
wget $ISO_URL

pveam update