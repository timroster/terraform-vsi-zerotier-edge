
resource "null_resource" "write_private_key" {
  provisioner "local-exec" {
    command = "echo '${module.vpcssh.private_key}' > .private-key && chmod 700 .private-key"
  }
}

resource "null_resource" "write_instance_ip" {
  provisioner "local-exec" {
    command = "echo -n '${module.zerotier-vnf.private_ips[0]}' > .instance-ip"
  }
}

resource "null_resource" "write_zt_public_key" {
  provisioner "local-exec" {
    command = "echo '${zerotier_identity.tester.public_key}' > .zt_identity-public_key"
  }
}

resource "null_resource" "write_zt_private_key" {
  provisioner "local-exec" {
    command = "echo '${zerotier_identity.tester.private_key}' > .zt_identity-private_key"
  }
}