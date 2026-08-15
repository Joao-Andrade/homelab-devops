# Creates the resources for the homelab, the LXCs and VMs.
# The management-node LXC is not managed here
# because it cannot be used to create itself.

# ---- REVERSE PROXY 01 LXC ----

# Reverse proxy 01 LXC
module "lxc-reverse-proxy-01" {
  source = "../../modules/lxc"

  node_name        = var.proxmox_node
  vm_id            = 101
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
