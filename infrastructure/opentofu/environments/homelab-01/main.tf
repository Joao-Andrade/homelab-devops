# Creates the resources for the homelab, the LXCs and VMs.
# The management-node LXC is not managed here
# because it cannot be used to create itself.

#################
#
# LXC containers
#
#################

# ---- REVERSE PROXY 01 LXC ----

# Reverse proxy 01 LXC
module "lxc-reverse-proxy-01" {
  source = "../../modules/lxc"

  node_name        = var.proxmox_node
  lxc_id           = 101
  hostname         = "homelab-lxc-reverse-proxy-01"
  description      = "Reverse proxy LXC"
  template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"

  cores     = 1
  memory    = 512
  disk_size = 20

  network_bridge = "vmbr0"
  mac_address    = "02:00:00:00:01:a2"
  ipv4_address   = "192.168.1.81/24"
  ipv4_gateway   = "192.168.1.1"
  firewall       = true

  ssh_public_keys = [var.ssh_public_key]
}

# Reverse proxy 01 enable firewall
resource "proxmox_virtual_environment_firewall_options" "lxc-reverse-proxy-01-firewall-options" {
  depends_on = [module.lxc-reverse-proxy-01]

  node_name    = var.proxmox_node
  container_id = module.lxc-reverse-proxy-01.vm_id

  enabled = true
}

# Reverse proxy 01 allow ssh from management nodes
resource "proxmox_virtual_environment_firewall_rules" "lxc-reverse-proxy-01-inbound" {
  depends_on = [
    module.lxc-reverse-proxy-01,
    proxmox_virtual_environment_firewall_options.lxc-reverse-proxy-01-firewall-options
  ]

  node_name    = var.proxmox_node
  container_id = module.lxc-reverse-proxy-01.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH from management nodes"
    source  = "+dc/management-nodes"
    macro   = "SSH"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTP from home network"
    source  = "+dc/home-network"
    macro   = "HTTP"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS from home network"
    source  = "+dc/home-network"
    macro   = "HTTPS"
    log     = "nolog"
  }
}

#################
#
# VMs
#
#################

# Cloud-init snippet for VMs
resource "proxmox_virtual_environment_file" "vm_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/../../cloud_configs/debian_setup_qemu_and_ssh.cfg", {
      ssh_public_key = var.ssh_public_key
    })
    file_name = "debian-cloud-config.yaml"
  }
}

# ---- VMS FOR KUBERNETES CLUSTER ----

module "k3s-nodes" {
  source   = "../../modules/vm"
  for_each = local.k3s_nodes

  depends_on = [
    proxmox_virtual_environment_file.vm_cloud_config
  ]

  hostname          = each.key
  vm_name           = each.key
  node_name         = var.proxmox_node
  vm_id             = each.value.vm_id
  cores             = each.value.cores
  memory            = each.value.memory
  memory_floating   = each.value.memory
  disk_size         = each.value.disk_size
  mac_address       = each.value.mac_address
  ipv4_address      = each.value.ipv4_address
  ipv4_gateway      = "192.168.1.1"
  user_data_file_id = proxmox_virtual_environment_file.vm_cloud_config.id
  firewall          = true
}

# VMs enable firewall
resource "proxmox_virtual_environment_firewall_options" "k3s-nodes-firewall-options" {
  for_each   = local.k3s_nodes
  depends_on = [module.k3s-nodes]

  node_name = var.proxmox_node
  vm_id     = each.value.vm_id

  enabled = true
}

# VMs allow ssh from management nodes
resource "proxmox_virtual_environment_firewall_rules" "k3s-nodes-inbound" {
  for_each = local.k3s_nodes
  depends_on = [
    module.k3s-nodes,
    proxmox_virtual_environment_firewall_options.k3s-nodes-firewall-options
  ]

  node_name = var.proxmox_node
  vm_id     = each.value.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH from management nodes"
    source  = "+dc/management-nodes"
    macro   = "SSH"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow kubectl access from management nodes"
    source  = "+dc/management-nodes"
    dport   = "6443"
    proto   = "tcp"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTP from reverse proxy nodes"
    source  = "+dc/reverse-proxy-nodes"
    macro   = "HTTP"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS from reverse proxy nodes"
    source  = "+dc/reverse-proxy-nodes"
    macro   = "HTTPS"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow k3s API server between k3s nodes"
    source  = "+dc/vm-network"
    dport   = "6443"
    proto   = "tcp"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow flannel VXLAN overlay between k3s nodes"
    source  = "+dc/vm-network"
    dport   = "8472"
    proto   = "udp"
    log     = "nolog"
  }
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow kubelet API between k3s nodes"
    source  = "+dc/vm-network"
    dport   = "10250"
    proto   = "tcp"
    log     = "nolog"
  }
}
