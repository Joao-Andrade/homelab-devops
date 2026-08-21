# Infrastructure

This folder contains the code to deploy and configure the VMs and LXCs in Proxmox using terraform and ansible.

## Folder structure

Check the infrastructure folder structure on the [documentation written about creating the LXCs](../docs/3-Create_and_conf_LXCs.md#terraform-and-ansible-folder-structure).

## Deploy

I used the tool OpenTofu to deploy the VMs and LXCs. I used the following commands:

```bash
cd infrastructure/opentofu/environments/homelab-01
tofu init
tofu plan
tofu apply
```

## Configure

I used ansible to configure the VMs and LXCs using the following commands:

```bash
cd infrastructure/ansible
ansible-playbook playbooks/reverse-proxy.yaml
ansible-playbook playbooks/kubernetes-control-plane.yaml
ansible-playbook playbooks/kubernetes-workers.yaml
```