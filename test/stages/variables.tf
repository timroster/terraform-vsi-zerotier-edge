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

variable "zt_network" {
  type = string

  validation {
    condition     = length(var.zt_network) == 16
    error_message = "The zt_network id must be be 16 characters long."
  }
  default = "a84ac5c10aaed526"
}