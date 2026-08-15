# Variables declarations

variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node where the resources will be created"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key to add to the root account of the LXCs and VMs"
  type        = string
}
