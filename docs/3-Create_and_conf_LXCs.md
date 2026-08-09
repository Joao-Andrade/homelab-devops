# Introduction

Now that I have Proxmox ready, I can create the VMs and LXCs as planned in the first article. The overall plan is to create 3 VMs for Kubernetes with K3s and 2 LXCs, one with a reverse proxy and the other with all the tools needed to manage everything, for example kubectl, ansible and opentofu.

Check out [architecture](./1-Architecture_and_hardware.md) for more details about the design and a high level overview of the architecture.

# Creating the first LXC

The first LXC I will deploy will be useful to manage the cluster, Proxmox and the other LXC with the reverse proxy.

There is a particularity with this LXC. This is the LXC that is going to have OpenTofu and Ansible to create and configure all the other VMs and LXC, but I cannot use it to create itself, so it needs to be created and configured either manually or I need to have opentofu and ansible installed on my pc to do this. I will explain both ways.

## Installing and configuring manually through web UI

### Creating the LXC

To create a LXC, select the node created and click on the Create CT on the top right. A pop up window will appear with a few tabs with settings to be configured. The Node and VM ID should be already filled, but if not, select correct node and the ID is whatever wanted. 

The following settings need to be configured:

- **General**
  - **Node**: The node where the LXC will be created
  - **VM ID**: The ID of the LXC
  - **Name**: The name of the LXC
  - **Template**: The template to be used to create the LXC
  - **Disk size**: The size of the disk to be used to create the LXC
  - **Memory**: The amount of memory to be used to create the LXC
  - **Swap**: The amount of swap to be used to create the LXC
  - **CPU**: The number of CPU cores to be used to create the LXC
  - **Network**: The network to be used to create the LXC
  - **IP address**: The IP address of the LXC
  - **Gateway**: The gateway of the LXC
  - **DNS**: The DNS server to be used to create the LXC

### Configuring the LXC

## Installing and configuring with OpenTofu and Ansible

### Creating the reverse proxy LXC

### Configuring the reverse proxy LXC

# Next steps

# Articles:

Heres the full list of articles of this series:

 - [1 - Architecture and Hardware](./1-Architecture_and_hardware.md)
 - [2 - Install Proxmox](./2-Install_proxmox.md)
 - [3 - Create and configure LXC](./3-Create_and_conf_LXC.md)
 - [4 - Create and configure VMs](./4-Create_and_conf_VMs.md)