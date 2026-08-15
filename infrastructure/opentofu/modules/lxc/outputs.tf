# Outputs of the lxc module

output "vm_id" {
  description = "ID of the created container"
  value       = proxmox_virtual_environment_container.lxc-container.vm_id
}

output "hostname" {
  description = "Hostname of the container"
  value       = var.hostname
}

output "mac_address" {
  description = "MAC address of the container"
  value       = var.mac_address
}

output "ipv4_addresses" {
  description = "IPv4 addresses of the container"
  value       = proxmox_virtual_environment_container.lxc-container.ipv4
}
