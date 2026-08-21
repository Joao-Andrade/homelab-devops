# Creates a Proxmox LXC container

resource "proxmox_virtual_environment_container" "lxc-container" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  description = var.description
  pool_id     = var.pool_id
  tags        = var.tags

  unprivileged = var.unprivileged

  features {
    nesting = var.nesting
  }

  initialization {
    hostname = var.hostname
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }
    user_account {
      keys = var.ssh_public_keys
    }
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.disk_datastore_id
    size         = var.disk_size
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  network_interface {
    name        = var.network_name
    bridge      = var.network_bridge
    mac_address = var.mac_address
    firewall    = var.firewall
  }

  start_on_boot = var.start_on_boot
  started       = var.started
}
