# What is this

This readme file shows how to clean up the homelab environment.

It has a few scripts that remove the resources that I created following my articles.

The order of the scripts is the reverse order of the articles, but following the same logic.

**IMPORTANT**:

- All the scripts are meant to be run on the Proxmox server with SSH, unless specified otherwise
  - Only the first step, the OpenTofu, is meant to be run on the management LXC
- All the scripts should be run with this repository cloned on the Proxmox server or on the management LXC
  - For the management LXC, it needs to have the tfstate file, meaning that I run the apply previously to have it

The order:

- [1 - Remove resources created with OpenTofu](#1---remove-resources-created-with-opentofu)
- [2 - Remove management LXC](#2---remove-management-lxc)
- [3 - Remove firewall settings applied on datacenter and node levels](#3---remove-firewall-settings-applied-on-datacenter-and-node-levels)
- [4 - Remove the ISO and LXC templates downloaded](#4---remove-the-iso-and-lxc-templates-downloaded)
- [5 - Remove terraform user and api token created](#5---remove-terraform-user-and-api-token-created)
- [6 - Remove proxmox user and group created](#6---remove-proxmox-user-and-group-created)
- [7 - Remove settings to allow access to Proxmox from SSH only with an ssh key](#7---remove-settings-to-allow-access-to-proxmox-from-ssh-only-with-an-ssh-key)
- [8 - What state is the homelab in after all the cleanup](#8---what-state-is-the-homelab-in-after-all-the-cleanup)

## 1 - Remove resources created with OpenTofu

On the management LXC, I can clean everything Opentofu created by running the following commands. This is assuming that the resources where already created with the OpenTofu code in this repository as well and there is the tfstate file on the LXC:

```bash
cd infrastructure/opentofu/environments/homelab-01
tofu destroy
```

## 2 - Remove management LXC

On the Proxmox server, I can remove the management LXC by running the following script `scripts/proxmox/cleanup_scripts/2-remove_management_lxc.sh`.

## 3 - Remove firewall settings applied on datacenter and node levels

On the Proxmox server, I can undo the firewall settings, the aliases and ipset created by running the following script `scripts/proxmox/cleanup_scripts/3-remove_firewall_and_aliases_ipsets.sh`.

## 4 - Remove the ISO and LXC templates downloaded

On the Proxmox server, I can remove the ISO and LXC templates by running the following script `scripts/proxmox/cleanup_scripts/4-remove_iso_and_template.sh`.

## 5 - Remove terraform user and api token created

On the Proxmox server, I can remove the terraform user and api token created by running the following script `scripts/proxmox/cleanup_scripts/5-remove_terraform_user_and_api_token.sh`.

## 6 - Remove proxmox user and group created

On the Proxmox server, I can remove the proxmox user and group created by running the following script `scripts/proxmox/cleanup_scripts/6-remove_proxmox_user_and_group.sh`.

## 7 - Remove settings to allow access to Proxmox from SSH only with an ssh key

On the Proxmox server, I can undo the settings to allow access to Proxmox from SSH only with an ssh key by running the following script `scripts/proxmox/cleanup_scripts/7-remove_root_only_ssh_key.sh`.

## 8 - What state is the homelab in after all the cleanup

Now the homelab is at the starting point, meaning that the Proxmox should be at the same state as when it was first installed, with no resources created.

I can now redo everything, do something else on Proxmox or just install some other OS on the SSD.