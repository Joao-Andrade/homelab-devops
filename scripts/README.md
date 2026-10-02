# Scripts

This folder contains scripts that may help configuring or cleaning up the homelab. There is a README file in each subfolder explaining the purpose of the scripts in that folder and the order they should be runned.

## Proxmox subfolder

Contains the scripts to setup and cleanup proxmox and should be executed from the Proxmox host. Scripts are divided into setup scripts and cleanup scripts and each subfolder has a README file.

## management-node subfolder

Contains scripts that should be executed from the management-node (the LXC created that serves as the central hub for managing the other LXCs and VMs, including the ones that will be part of a kubernetes cluster). It contains various scripts to do different tasks.
