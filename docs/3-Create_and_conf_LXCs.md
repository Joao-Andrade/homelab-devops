# Introduction

Now that I have Proxmox ready, I can create the VMs and LXCs as planned in the first article. The overall plan is to create 3 VMs for Kubernetes with K3s and 2 LXCs, one with a reverse proxy and the other with all the tools needed to manage everything, for example kubectl, ansible and opentofu.

Check out [architecture](./1-Architecture_and_hardware.md) for more details about the design and a high level overview of the architecture.

# Creating the first LXC

The first LXC I will deploy will be useful to manage the cluster, Proxmox and the other LXC with the reverse proxy.

There is a particularity with this LXC. This is the LXC that is going to have OpenTofu and Ansible to create and configure all the other VMs and LXC, but I cannot use it to create itself, so it needs to be created and configured either manually or through a script. I will explain both ways.

I could do it through OpenTofu and Ansible from my pc, but I want to not need any tool on my pc.

## Installing and configuring manually through web UI

### Creating the LXC

To create a LXC, select the node created and click on the Create CT on the top right. A pop up window will appear with a few tabs with settings to be configured. The Node and VM ID should be already filled, but if not, select correct node and the ID is whatever wanted.

The first tab contains the general information:

 - Node
   - The node where the LXC will be created
 - VM ID
   - The ID of the LXC, can be anything
 - Hostname
   - The hostname it should have
 - Unprivileged container
   - Normally every container should be unpreviledge, unless some specific use case, because it can give access to the host system
 - Nesting
   - Allows the LXC to create other containers, for example to virtualize or containerize something else. I didn't enable it because I do not need to do that on this LXC
 - Add to HA
   - Only necessary if you have more than one Proxmox node and want to use the High Availability feature. I only have one node, so I didn't enable it
 - Resource Pool
   - This allows to organize the resources, like VMs and LXCs into groups. This is useful for example if I had different environments, each with its own VMs and LXCs, and I wanted to easily manage each group of VMs on a specific environment. I don't need that for now.
 - Password
   - The password for the root user. Not needed if don't want to access through ssh with password
 - SSH public key
   - The public key to access to root through ssh

![Creating LXC general](./images/3-create-lxc-1.png)

The next tab is Template:

Here I selected the Debian template.

![Creating LXC template](./images/3-create-lxc-2.png)

Next is Disk. I set to 20 GB, like on the architecuture overview from the [first article](./1-Architecture_and_hardware.md#architecture).

![Creating LXC disk](./images/3-create-lxc-3.png)

Next is CPU. I set to 1 core.

![Creating LXC CPU](./images/3-create-lxc-4.png)

Next is Memory. I set to 512 MB.

![Creating LXC memory](./images/3-create-lxc-5.png)

Next is Network. Here I Specified the MAC and static IP address. Again, to respect the Network values from the [first article](./1-Architecture_and_hardware.md#network).
![Creating LXC network](./images/3-create-lxc-6.png)

Next is DNS. I leave as default since it will use the same as the Proxmox node.

![Creating LXC dns](./images/3-create-lxc-7.png)

Next confirm to create the LXC. It should appear on the left side the LXC created.

### Configuring the LXC

Once the LXC is created it should be possible to access it through ssh, like `ssh root@[IP_of_lxc] -i <path_to_private_key>`.

To avoid placing the ip and path to the ssh private key, I edited the ssh config file `~/.ssh/config` and added the following lines:

```
host homelab-mn
  host [IP_OF_LXC]
  user root
  identityfile <path_to_private_key>
```

Now to access, I just need to type `ssh homelab-mn` on the terminal.

What I installed here was git, ansible, opentofu, kubectl and argocd cli.

## Installing and configuring with a script

# Creating the reverse proxy LXC

# Configuring the reverse proxy LXC

# Next steps

# Articles:

Heres the full list of articles of this series:

 - [1 - Architecture and Hardware](./1-Architecture_and_hardware.md)
 - [2 - Install Proxmox](./2-Install_proxmox.md)
 - [3 - Create and configure LXCs](./3-Create_and_conf_LXCs.md)
 - [4 - Create and configure VMs](./4-Create_and_conf_VMs.md)