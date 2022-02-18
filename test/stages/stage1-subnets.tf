module "subnets" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-subnets.git"

  resource_group_id = module.resource_group.id
  region            = var.region
  vpc_name          = module.vpc.name
  gateways          = module.gateways.gateways
  provision         = true
  _count            = var.vpc_subnet_count
  label             = "proxy"
  acl_rules = [{
    name        = "inbound-ssh"
    action      = "allow"
    direction   = "inbound"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
  }]
}
