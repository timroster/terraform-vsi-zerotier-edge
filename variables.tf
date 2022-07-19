## IBM Cloud account variables
variable "resource_group_id" {
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

## Instance configuration variables
variable "image_name" {
  type        = string
  description = "The name of the image to use for the virtual server"
  default     = "ibm-rocky-linux-8-6-minimal-amd64-1"
}

variable "profile_name" {
  type        = string
  description = "Instance profile to use for the zerotier instance"
  default     = "cx2-2x4"
}

variable "label" {
  type        = string
  description = "The label for the server instance"
  default     = "zerotier"
}

variable "ssh_key_id" {
  type        = string
  description = "Existing SSH key ID to inject into the virtual server instance"
}

variable "create_public_ip" {
  type        = bool
  description = "Set whether to allocate a public IP address for the virtual server instance"
  default     = false
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Tags that should be added to the instance"
}

variable "kms_enabled" {
  type        = bool
  description = "Flag indicating that the volumes should be encrypted using a KMS."
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The crn of the root key in the kms instance. Required if kms_enabled is true"
  default     = null
}

variable "auto_delete_volume" {
  type        = bool
  description = "Flag indicating that any attached volumes should be deleted when the instance is deleted"
  default     = true
}

## variables for VPC and networking properties for instance
variable "vpc_name" {
  type        = string
  description = "The name of the vpc instance"
}

variable "vpc_subnet_count" {
  type        = number
  description = "Number of vpc subnets"
}

variable "vpc_subnets" {
  type = list(object({
    label = string
    id    = string
    zone  = string
  }))
  description = "List of subnets with labels"
}

variable "base_security_group" {
  type        = string
  description = "The id of the base security group to use for the VSI instance. If not provided the default VPC security group will be used."
  default     = null
}

variable "security_group_rules" {
  # type = list(object({
  #   name=string,
  #   direction=string,
  #   remote=optional(string),
  #   ip_version=optional(string),
  #   tcp=optional(object({
  #     port_min=number,
  #     port_max=number
  #   })),
  #   udp=optional(object({
  #     port_min=number,
  #     port_max=number
  #   })),
  #   icmp=optional(object({
  #     type=number,
  #     code=optional(number)
  #   })),
  # }))
  description = "List of security group rules to set on the zerotier security group in addition to the SSH rules"
  default     = []
}

variable "allow_ssh_from" {
  type        = string
  description = "An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the virtual server, will be combined with the zerotier network in the security group"
  default     = null
}

## variables used in init script
variable "script" {
  type    = string
  default = "init-server.tpl"
}

variable "zt_network" {
  type = string

  validation {
    condition     = length(var.zt_network) == 16
    error_message = "The zt_network id must be be 16 characters long."
  }
}

variable "zt_instances" {
  default = {
    1 = {
      ip_assignment = "192.168.192.100",
      description   = "zt-vnf-zone-1",
      route         = "10.16.0.0/18",
    },
    2 = {
      ip_assignment = "192.168.192.101",
      description   = "zt-vnf-zone-2",
      route         = "10.16.64.0/18",
    },
    3 = {
      ip_assignment = "192.168.192.102",
      description   = "zt-vnf-zone-3",
      route         = "10.16.128.0/18",
    }
  }
}

variable "allow_network" {
  type        = string
  description = "The internal ip address range that should be allowed to use the proxy server"
  default     = "10.0.0.0/8"
}

variable "provision_squid" {
  type        = bool
  description = "Set whether to allocate a public IP address for the virtual server instance"
  default     = false
}