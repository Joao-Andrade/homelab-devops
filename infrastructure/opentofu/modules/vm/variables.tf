# Variables declarations for the vm module

variable "hostname" {
  description = "Hostname of the VM"
  type        = string
}

variable "node_name" {
  description = "Proxmox node where the VM will be created"
  type        = string
}

variable "vm_id" {
  description = "VM ID"
  type        = number
}

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "description" {
  description = "Description of the VM"
  type        = string
  default     = "Managed by OpenTofu"
}

variable "pool_id" {
  description = "Resource pool to assign the VM to"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the VM"
  type        = list(string)
  default     = []
}

variable "disk_image_file_id" {
  description = "ID/path of the disk image to import for the VM's boot disk"
  type        = string
  default     = "local:import/debian-13-generic-amd64-20260601-2496.qcow2"
}

variable "cores" {
  description = "Number of vCPU cores"
  type        = number
  default     = 2
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "memory" {
  description = "RAM memory in MB"
  type        = number
}

variable "disk_datastore_id" {
  description = "Proxmox storage ID"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "mac_address" {
  description = "MAC address for the network interface. Leave null to let Proxmox generate one"
  type        = string
  default     = null
}

variable "network_bridge" {
  description = "Network bridge to attach the VM to"
  type        = string
  default     = "vmbr0"
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

variable "user_data_file_id" {
  description = "ID of the cloud-init user data file (snippet) to attach to this VM"
  type        = string
}

variable "start_on_boot" {
  description = "Automatically start the VM when the host boots"
  type        = bool
  default     = true
}

variable "started" {
  description = "Whether the VM should be running"
  type        = bool
  default     = true
}
