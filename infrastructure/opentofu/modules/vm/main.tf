resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.node_name
  vm_id     = var.vm_id

  cpu {
    cores   = var.cores
    sockets = var.sockets
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.disk_size
    import_from  = "local:import/debian-13-generic-amd64-20260601-2496.qcow2"
  }

  agent {
    enabled = true
  }

  serial_device {}

  network_device {
    bridge      = "vmbr0"
    mac_address = var.mac_address
    firewall    = var.firewall
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }
    user_data_file_id = var.user_data_file_id
  }
}
