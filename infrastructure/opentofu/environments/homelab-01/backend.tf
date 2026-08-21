terraform {
  backend "local" {
    path = "../../states/homelab-01.tfstate"
  }
}
