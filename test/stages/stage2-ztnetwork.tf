module "zt-network" {
  source  = "zerotier/network/zerotier"
  version = "1.0.2"
  name = "vnf-module-test"
  subnets = [ "192.168.192.0/24" ]
}