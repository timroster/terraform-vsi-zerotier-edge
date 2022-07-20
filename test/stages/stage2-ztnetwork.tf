module "zt-network" {
  source  = "zerotier/network/zerotier"
  version = "1.0.2"
  name = "vnf-module-test"
  subnets = [ var.zt_network_cidr ]
}