# Infrastructure

This folder contains the code to deploy and configure the VMs and LXCs in Proxmox using terraform and ansible. It also contains the helm charts of the applications deployed on the cluster.

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

# Deploy applications

I use helm-charts to deploy any application on the cluster. Inside each application folder, there should be instructions to deploy the application. For example, here is a list of the applications I have deployed and instructions on how to deploy them:

- [GitLab](./helm-charts/source-control/gitlab/README.md)
- [Gitea](./helm-charts/source-control/gitea/README.md)