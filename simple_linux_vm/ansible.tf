resource "ansible_host" "my_ec2" {
  name   = azurerm_public_ip.publicip.fqdn 
  groups = ["nginx"]
  variables = {
    ansible_user                 = var.adminUsername,
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
}