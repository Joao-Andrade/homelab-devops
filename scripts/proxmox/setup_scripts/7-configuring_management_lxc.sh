#!/bin/bash

# This script configures the first LXC on Proxmox
# This uses a Debian template and will be used
# to manage and access to every other VM or LXC
set -e

# Variables
UBUNTU_CODENAME=jammy # For ansible

# Update and upgrade packages
echo "Updating and upgrading packages"
apt update -y
apt upgrade -y

echo "Installing curl"
apt install curl -y

echo "Installing gpg"
apt install gpg -y

echo "Installing git"
apt install git -y

echo "Installing kubectl"
apt install kubectl -y

echo "Installing ansible"
apt install ansible -y

# go to tmp folder because of curls
cd /tmp

# Install helm
echo "installing helm"
# https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Install opentofu
# https://opentofu.org/docs/intro/install/deb/
echo "Installing opentofu"
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh

# Install argocd cli
# https://argo-cd.readthedocs.io/en/stable/cli_installation/#download-with-curl
echo "Installing argocd cli"
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64