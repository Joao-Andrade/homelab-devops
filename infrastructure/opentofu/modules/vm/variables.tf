variable "node_name" {
  description = "Proxmox node where the VM will be created"
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
  description = "RAM memory in MB"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GB"
}

variable "mac_address" {
  type        = string
  description = "MAC address for the network interface. Leave null to let Proxmox generate one"
  default     = null
}

variable "ipv4_address" {
  type        = string
  description = "IPv4 address or 'dhcp'"
  default     = "dhcp"
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 gateway or null if address is 'dhcp'"
  default     = "dhcp"
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
