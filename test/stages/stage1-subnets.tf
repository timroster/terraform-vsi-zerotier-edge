module "subnets" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-subnets.git"

  resource_group_name = module.resource_group.name
  region              = var.region
  vpc_name            = module.vpc.name
  gateways            = module.gateways.gateways
  provision           = true
  _count              = var.vpc_subnet_count
  label               = "proxy"
  acl_rules = [{
    name        = "inbound-ssh"
    action      = "allow"
    direction   = "inbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    tcp={
       port_min=22,
       port_max=22,
       source_port_min=1,
       source_port_max=65535
     }
  },{
    name        = "outbound-ssh"
    action      = "allow"
    direction   = "outbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
      tcp={
       port_min=1,
       port_max=65535,
       source_port_min=22,
       source_port_max=22
     }
  }]
}
