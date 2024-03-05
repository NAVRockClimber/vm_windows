resource "ansible_host" "example" {
  name   = azurerm_public_ip.publicip.fqdn 
  groups = ["nginx"]
  variables = {
    ansible_user                 = var.adminUsername,
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
    ansible_ssh_common_args="-o StrictHostKeyChecking=no"
  }
}

resource "ansible_playbook" "example_2" {
  depends_on = [ansible_host.example, azurerm_linux_virtual_machine.example]
  playbook = "simple-playbook.yaml"

  # inventory configuration
  name   = azurerm_public_ip.publicip.fqdn 
  
  # connection configuration and other vars
  extra_vars = {
    inventory_file = "inventory.yaml"
    ansible_hostname   = ansible_host.example.name
    inventory_hostname = ansible_host.example.name
    ansible_user = var.adminUsername
    # injected_variable  = "Hello from simple.tf!"
    ansible_check_mode = true
  }
  ignore_playbook_failure = true 
  verbosity=3
}

output "playbook_stderr" {
  value = ansible_playbook.example_2.ansible_playbook_stderr
}

# output stdout
output "playbook_stdout" {
    value = ansible_playbook.example_2.ansible_playbook_stdout
}