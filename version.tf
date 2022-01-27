terraform {
  required_version = ">= 0.15.0"

  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      version = ">= 1.17"
    }
    zerotier = {
      source = "zerotier/zerotier"
    }
  }
}
