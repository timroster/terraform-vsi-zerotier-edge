
resource "null_resource" "write_private_key" {
  provisioner "local-exec" {
    command = "echo '${module.vpcssh.private_key}' > .private-key && chmod 700 .private-key"
  }
}

resource "null_resource" "write_public_ip" {
  provisioner "local-exec" {
    command = "echo -n '${module.zerotier-vnf.public_ips[0]}' > .public-ip"
  }
}
