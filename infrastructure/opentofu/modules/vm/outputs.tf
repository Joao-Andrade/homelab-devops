# Outputs of the vm module

output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "VM name"
  value       = var.vm_name
}

output "mac_address" {
  description = "MAC address"
  value       = var.mac_address
}

output "ipv4_addresses" {
  description = "IPv4 addresses"
  value       = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
