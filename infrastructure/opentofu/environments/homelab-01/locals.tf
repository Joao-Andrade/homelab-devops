locals {
  k3s_nodes = {
    "k3s-cp01" = {
      vm_id       = 200
      mac_address = "02:00:00:00:02:a1"
      ip_address  = "192.168.1.100/24"
      cores       = 2
      memory      = 4096
      disk_size   = 60
    }
    "k3s-wk01" = {
      vm_id       = 201
      mac_address = "02:00:00:00:02:a2"
      ip_address  = "192.168.1.101/24"
      cores       = 4
      memory      = 8192
      disk_size   = 250
    }
    "k3s-wk02" = {
      vm_id       = 202
      mac_address = "02:00:00:00:02:a3"
      ip_address  = "192.168.1.102/24"
      cores       = 4
      memory      = 8192
      disk_size   = 250
    }
  }
}
