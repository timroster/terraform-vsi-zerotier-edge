locals {
  subnets             = data.ibm_is_subnet.vpc_subnet
  tags                = tolist(setsubtract(concat(var.tags, ["proxy"]), [""]))
  name                = "${replace(var.vpc_name, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${var.label}"
  base_security_group = var.base_security_group != null ? var.base_security_group : data.ibm_is_vpc.vpc.default_security_group
  ssh_security_group_rule = var.allow_ssh_from != null ? [{
    name      = "ssh-inbound"
    direction = "inbound"
    remote    = var.allow_ssh_from
    tcp = {
      port_min = 22
      port_max = 22
    }
  }] : []
  server_network_rules = [{
    name      = "zerotier-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    udp = {
      port_min = 9993
      port_max = 9993
    }
  }, {
    name      = "squid-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    tcp = {
      port_min = 3128
      port_max = 3128
    }
  }, {
    name      = "zt-outbound-udp"
    direction = "outbound"
    remote    = "0.0.0.0/0"
    udp = {
      port_min = 1
      port_max = 65535
    }
  }, {
    name      = "zt-outbound-tcp"
    direction = "outbound"
    remote    = "0.0.0.0/0"
    tcp = {
      port_min = 1
      port_max = 65535
    }
  }]
  security_group_rules = concat(local.ssh_security_group_rule, var.security_group_rules, local.server_network_rules)
  zt_network_cidr = [for route in data.zerotier_network.this.route : route.target if route.via == ""]
}

# get the information about the existing vpc instance
data ibm_is_vpc vpc {
  depends_on = [null_resource.print-names]

  name           = var.vpc_name
}

data ibm_is_subnet vpc_subnet {
  count = var.vpc_subnet_count

  identifier = var.vpc_subnets[count.index].id
}

data "ibm_is_vpc_default_routing_table" "vpc_route" {
    vpc = data.ibm_is_vpc.vpc.id
}

# get details on zerotier network
data zerotier_network this {
  id = var.zt_network
}

resource null_resource print-names {
  provisioner "local-exec" {
    command = "echo 'VPC name: ${var.vpc_name}'"
  }
  provisioner "local-exec" {
    command = "echo 'Resource group id: ${var.resource_group_id}'"
  }
}

resource ibm_is_security_group vsi {
  name           = "${local.name}-group"
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource ibm_is_security_group_rule additional_rules {
  count = length(local.security_group_rules)

  group      = ibm_is_security_group.vsi.id
  direction  = local.security_group_rules[count.index]["direction"]
  remote     = lookup(local.security_group_rules[count.index], "remote", null)
  ip_version = lookup(local.security_group_rules[count.index], "ip_version", null)

  dynamic "tcp" {
    for_each = lookup(local.security_group_rules[count.index], "tcp", null) != null ? [ lookup(local.security_group_rules[count.index], "tcp", null) ] : []

    content {
      port_min = tcp.value["port_min"]
      port_max = tcp.value["port_max"]
    }
  }

  dynamic "udp" {
    for_each = lookup(local.security_group_rules[count.index], "udp", null) != null ? [ lookup(local.security_group_rules[count.index], "udp", null) ] : []

    content {
      port_min = udp.value["port_min"]
      port_max = udp.value["port_max"]
    }
  }

  dynamic "icmp" {
    for_each = lookup(local.security_group_rules[count.index], "icmp", null) != null ? [ lookup(local.security_group_rules[count.index], "icmp", null) ] : []

    content {
      type = icmp.value["type"]
      code = lookup(icmp.value, "code", null)
    }
  }
}

data ibm_is_image image {
  name = var.image_name
}

resource ibm_is_instance vsi {
  depends_on = [ibm_is_security_group_rule.additional_rules]
  count = var.vpc_subnet_count

  name           = "${local.name}${format("%02s", count.index)}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.vpc_subnets[count.index].zone
  profile        = var.profile_name
  image          = data.ibm_is_image.image.id
  keys           = tolist(setsubtract([var.ssh_key_id], [""]))
  resource_group = var.resource_group_id
  auto_delete_volume = var.auto_delete_volume

  user_data = data.cloudinit_config.this.rendered

  primary_network_interface {
    subnet          = var.vpc_subnets[count.index].id
    security_groups = [local.base_security_group, ibm_is_security_group.vsi.id]
    allow_ip_spoofing = true
  }

  boot_volume {
    name       = "${local.name}${format("%02s", count.index)}-boot"
    encryption = var.kms_enabled ? var.kms_key_crn : null
  }

  tags = var.tags
}

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/${var.script}", {
      "zt_network"  = var.zt_network
    })
  }
}

resource ibm_is_floating_ip vsi {
  count = var.create_public_ip ? var.vpc_subnet_count : 0

  name           = "${local.name}${format("%02s", count.index)}-ip"
  target         = ibm_is_instance.vsi[count.index].primary_network_interface[0].id
  resource_group = var.resource_group_id

  tags = var.tags
}

# add route to ZeroTier network through VSI
resource "ibm_is_vpc_routing_table_route" "zt_ibm_is_vpc_routing_table_route" {
  count = length(local.zt_network_cidr)

  vpc = data.ibm_is_vpc.vpc.id
  routing_table = data.ibm_is_vpc_default_routing_table.vpc_route.id
  zone = var.vpc_subnets[0].zone
  name = "${local.name}${format("%02s", count.index)}-ztgw"
  destination = local.zt_network_cidr[count.index]
  action = "deliver"
  next_hop = ibm_is_instance.vsi[0].primary_network_interface[0].primary_ipv4_address
}