module "vpcssh" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-vpc-ssh.git"

  resource_group_name = module.resource_group.name
  name_prefix         = var.name_prefix
  public_key          = ""
  private_key         = ""
}
