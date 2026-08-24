# Creates a Proxmox VM

# Per-VM cloud-init metadata snippet, just for the hostname and instance id.
# Since this is specific for each VM, it cannot be a reusable cloud-init snippet.
resource "proxmox_virtual_environment_file" "vm_meta_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data      = "#cloud-config\ninstance-id: ${var.vm_id}\nlocal-hostname: ${var.hostname}\n"
    file_name = "meta-data-${var.vm_id}.yaml"
  }
}

# The VM resource
resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  node_name   = var.node_name
  vm_id       = var.vm_id
  description = var.description
  pool_id     = var.pool_id
  tags        = var.tags

  cpu {
    cores   = var.cores
    sockets = var.sockets
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.disk_datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    import_from  = var.disk_image_file_id
  }

  agent {
    enabled = true
    # timeout = 60
  }

  serial_device {}

  network_device {
    bridge      = var.network_bridge
    mac_address = var.mac_address
    firewall    = var.firewall
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }
    user_data_file_id = var.user_data_file_id
    meta_data_file_id = proxmox_virtual_environment_file.vm_meta_config.id
  }

  on_boot = var.start_on_boot
  started = var.started
}
