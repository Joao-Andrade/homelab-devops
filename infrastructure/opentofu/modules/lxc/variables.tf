# Variables declarations for the lxc module

variable "node_name" {
  description = "Proxmox node where the container will be created"
  type        = string
}

variable "vm_id" {
  description = "Container ID (VMID)"
  type        = number
}

variable "hostname" {
  description = "Hostname of the container"
  type        = string
}

variable "description" {
  description = "Description of the container"
  type        = string
  default     = "Managed by OpenTofu"
}

variable "pool_id" {
  description = "Resource pool to assign the container to"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the container"
  type        = list(string)
  default     = []
}

variable "template_file_id" {
  description = "ID of the OS template to use"
  type        = string
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "debian"
}

variable "unprivileged" {
  description = "Container is on unprivileged mode"
  type        = bool
  default     = true
}

variable "nesting" {
  description = "Whether the container is allowed to nest"
  type        = bool
  default     = false
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Dedicated memory in MB"
  type        = number
  default     = 512
}

variable "swap" {
  description = "Swap size in MB"
  type        = number
  default     = 0
}

variable "disk_datastore_id" {
  description = "Proxmox storage ID"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "network_bridge" {
  description = "Network bridge to attach the container to"
  type        = string
  default     = "vmbr0"
}

variable "network_name" {
  description = "Name of the network interface of the container"
  type        = string
  default     = "eth0"
}

variable "mac_address" {
  description = "MAC address for the network interface. Leave null to let Proxmox generate one"
  type        = string
  default     = null
}

variable "firewall" {
  description = "Whether this interface's firewall rules should be used"
  type        = bool
  default     = true
}

variable "ipv4_address" {
  description = "IPv4 address or 'dhcp'"
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway or null if address is 'dhcp'"
  type        = string
  default     = null
}

variable "ssh_public_keys" {
  description = "SSH public keys"
  type        = list(string)
}

variable "start_on_boot" {
  description = "Automatically start the container when the host boots"
  type        = bool
  default     = true
}

variable "started" {
  description = "Whether the container should be running"
  type        = bool
  default     = true
}
