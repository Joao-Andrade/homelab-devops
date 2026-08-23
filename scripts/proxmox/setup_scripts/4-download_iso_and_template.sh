#!/bin/bash

# This script downloads Images and templates to Proxmox
# The image is a debian and the templates is also debian
set -e

# Variables
IMAGE_URL="https://cloud.debian.org/images/cloud/trixie/20260601-2496/debian-13-generic-amd64-20260601-2496.qcow2"
DEBIAN_TEMPLATE="debian-13-standard_13.6-1_amd64.tar.zst"

echo "Downloading Debian template $DEBIAN_TEMPLATE"
pveam download local $DEBIAN_TEMPLATE

echo "Downloading image from $IMAGE_URL"
cd /var/lib/vz/import
wget $IMAGE_URL

echo "Updating pveam database"
pveam update