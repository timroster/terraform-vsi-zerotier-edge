terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.17"
    }
  }
  required_version = ">= 0.15"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

data "ibm_is_ssh_key" "existing" {
  name = var.ssh_key_name
}

module "zerotier-vnf" {
  source = "../"

  resource_group_id = var.resource_group_id
  region            = var.region
  ibmcloud_api_key  = var.ibmcloud_api_key
  ssh_key_id        = data.ibm_is_ssh_key.existing.id
  vpc_name          = var.vpc_name
  vpc_subnet_count  = var.vpc_subnet_count
  vpc_subnets       = var.vpc_subnets
  zt_network        = var.zt_network
}

resource "local_file" "proxy-config" {
  filename = "proxy-config.yaml"
  content  = module.zerotier-vnf.proxy-config-yaml
}

resource "local_file" "setcrioproxy" {
  filename = "setcrioproxy.yaml"
  content  = module.zerotier-vnf.setcrioproxy-yaml
}

output "zerotier_network_cidr" {
  description = "ZeroTier LAN address"
  value       = module.zerotier-vnf.zerotier_network_cidr
}

output "private_ip_address" {
  value = module.zerotier-vnf.private_ips
}