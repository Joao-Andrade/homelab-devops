# Providers are to specify where to connect.

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    # force private key instead of relying on agent
    agent       = false
    username    = "root"
    private_key = file(pathexpand(var.proxmox_ssh_private_key_path))
  }
}
