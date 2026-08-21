# What is this

This readme file shows how to set up the homelab environment.

It has a few scripts that allows to set up easily the homelab following my articles.

The order of the scripts is the same order of the articles.

**IMPORTANT**:

- The first six scripts are meant to be run on the Proxmox server with SSH
- From the seventh script onwards, it is meant to be run on the management LXC
- All the scripts should be run with this repository cloned on the Proxmox server or on the management LXC

The order:

- [1 - Update settings to allow access to Proxmox from SSH only with an ssh key](#1---update-settings-to-allow-access-to-proxmox-from-ssh-only-with-an-ssh-key)
- [2 - Add a new proxmox user and group](#2---add-a-new-proxmox-user-and-group)
- [3 - Add a new terraform user and api token](#3---add-a-new-terraform-user-and-api-token)
- [4 - Download the ISO and LXC templates](#4---download-the-iso-and-lxc-templates)
- [5 - Add firewall settings applied on datacenter and node levels](#5---add-firewall-settings-applied-on-datacenter-and-node-levels)
- [6 - Create the management LXC](#6---create-the-management-lxc)
- [7 - Configure the management LXC](#7---configure-the-management-lxc)
- [8 - Create the reverse proxy LXC with OpenTofu](#8---create-the-reverse-proxy-lxc-with-opentofu)
- [9 - Apply configuration to LXC with Ansible](#9---apply-configuration-to-lxc-with-ansible)
- [10 - What state is the homelab in after all the setup](#10---what-state-is-the-homelab-in-after-all-the-setup)

## 1 - Update settings to allow access to Proxmox from SSH only with an ssh key

On the Proxmox server, I updated the settings to allow access to Proxmox from SSH only with an ssh key by running the following script `scripts/proxmox/setup_scripts/1-root_only_ssh_key.sh`.

## 2 - Add a new proxmox user and group

On the Proxmox server, I added a new user and group by running the following script `scripts/proxmox/setup_scripts/2-add_proxmox_user_and_group.sh`.

## 3 - Add a new terraform user and api token

On the Proxmox server, I added a new terraform user and api token by running the following script `scripts/proxmox/setup_scripts/3-create_terraform_user_and_api_token.sh`.

## 4 - Download the ISO and LXC templates

On the Proxmox server, I downloaded the ISO and LXC templates by running the following script `scripts/proxmox/setup_scripts/4-download_iso_and_template.sh`.

## 5 - Add firewall settings applied on datacenter and node levels

On the Proxmox server, I added the firewall settings, the aliases and ipset by running the following script `scripts/proxmox/setup_scripts/5-enable_firewall_and_aliases_ipsets.sh`.

## 6 - Create the management LXC

On the Proxmox server, I created the management LXC by running the following script `scripts/proxmox/setup_scripts/6-creating_management_lxc.sh`.

## 7 - Configure the management LXC

On the management LXC, I configure it by running the following script `scripts/proxmox/setup_scripts/7-configuring_management_lxc.sh`.

## 8 - Create the reverse proxy LXC with OpenTofu

On the management LXC, I created the reverse proxy LXC by running the following commands:

```bash
cd infrastructure/opentofu/environments/homelab-01
tofu init
tofu plan
tofu apply
```

## 9 - Apply configuration to LXC with Ansible

On the management LXC, I configured the LXC using Ansible. For that, I run the following playbook:

```bash
cd infrastructure/ansible
ansible-playbook playbooks/reverse-proxy.yaml
ansible-playbook playbooks/kubernetes-control-plane.yaml
ansible-playbook playbooks/kubernetes-workers.yaml
```

## 10 - What state is the homelab in after all the setup

Now the homelab is set up and ready to use.