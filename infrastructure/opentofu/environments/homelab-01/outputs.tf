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

output "k3s_nodes_vm_id" {
  description = "VM ID of each k3s node"
  value       = { for name, node in module.k3s-nodes : name => node.vm_id }
}

output "k3s_nodes_hostname" {
  description = "Hostname of each k3s node"
  value       = { for name, node in module.k3s-nodes : name => node.vm_name }
}

output "k3s_nodes_mac_address" {
  description = "MAC address of each k3s node"
  value       = { for name, node in module.k3s-nodes : name => node.mac_address }
}

output "k3s_nodes_ipv4_addresses" {
  description = "IPv4 addresses of each k3s node"
  value       = { for name, node in module.k3s-nodes : name => node.ipv4_addresses }
}
