variable "node_name" {
  description = "Proxmox node where the container will be created"
  type        = string
}

variable "vm_id" {
  type        = number
  description = "VM ID"
}

variable "vm_name" {
  type        = string
  description = "VM name"
}

variable "cores" {
  type        = number
  description = "vCPU cores"
  default     = 2
}

variable "sockets" {
  type        = number
  description = "Number of CPU sockets"
  default     = 1
}

variable "memory" {
  type        = number
  description = "RAM Memory in MB"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GB"
}

variable "mac_address" {
  type        = string
  description = "MAC address for the network interface"
}

variable "ip_address" {
  type        = string
  description = "Static IP in CIDR format (ex: 192.168.1.50/24)"
}

variable "gateway" {
  type        = string
  description = "Gateway IP address"
  default     = "192.168.1.1"
}

variable "firewall" {
  description = "Enable firewall"
  type        = bool
  default     = true
}

variable "user_data_file_id" {
  description = "ID of the cloud-init user data file (snippet) to attach to this VM"
  type        = string
}
