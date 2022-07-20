module "zerotier-vnf" {
  #source = "./module"
  source = "../../"

  resource_group_id = module.resource_group.id
  region            = var.region
  ibmcloud_api_key  = var.ibmcloud_api_key
  ssh_key_id        = module.vpcssh.id
  vpc_name          = module.vpc.name
  vpc_subnet_count  = module.subnets.count
  vpc_subnets       = module.subnets.subnets
  zt_network        = module.zt-network.id
  zt_network_cidr   = var.zt_network_cidr
  create_public_ip  = true
  allow_ssh_from    = "0.0.0.0/0"
}