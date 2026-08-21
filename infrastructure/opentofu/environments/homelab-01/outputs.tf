# Outputs shown after applying the terraform code

output "lxc_reverse_proxy_01_vm_id" {
  description = "VM ID of the reverse proxy LXC"
  value       = module.lxc-reverse-proxy-01.vm_id
}

output "lxc_reverse_proxy_01_hostname" {
  description = "Hostname of the reverse proxy LXC"
  value       = module.lxc-reverse-proxy-01.hostname
}

output "lxc_reverse_proxy_01_mac_address" {
  description = "MAC address of the reverse proxy LXC"
  value       = module.lxc-reverse-proxy-01.mac_address
}

output "lxc_reverse_proxy_01_ipv4_addresses" {
  description = "IPv4 addresses of the reverse proxy LXC"
  value       = module.lxc-reverse-proxy-01.ipv4_addresses
}
