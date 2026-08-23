# Outputs of the vm module

output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}
