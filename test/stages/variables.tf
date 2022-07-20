## IBM Cloud account variables
variable "resource_group_name" {
  type        = string
  description = "The id of the IBM Cloud resource group where the VPC has been provisioned."
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the cluster will be/has been installed."
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of vpc subnets"
  default     = 0
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "zt_network_cidr" {
  type        = string
  description = "The ZeroTier default LAN segment for nodes"
  default     = "192.168.192.0/24"
}