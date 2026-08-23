#!/bin/bash

# This script deletes the images and templates on Proxmox
# The image is a debian and the templates is debian
set -e

# Variables
IMAGE="debian-13-generic-amd64-20260601-2496.qcow2"
DEBIAN_TEMPLATE="vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"

# ---- Remove templates
echo "Removing Debian template $DEBIAN_TEMPLATE"
pveam remove local:$DEBIAN_TEMPLATE

# ---- Remove ISO
echo "Removing Image $IMAGE"
cd /var/lib/vz/import
rm $IMAGE

pveam update