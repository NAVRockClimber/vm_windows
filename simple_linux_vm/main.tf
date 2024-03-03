## <https://www.terraform.io/docs/providers/azurerm/index.html>
provider "azurerm" {
  features {}

  tenant_id = var.Azure.tenant_id
  subscription_id = var.Azure.subscription_id
}

locals {
  name_prefix = var.Prefixes
}

locals {
  name_suffix = "${random_string.name.result}"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}

output "ssh-to-vm" {
  value = "ssh -l ${var.adminUsername} ${azurerm_public_ip.publicip.fqdn}"
}

output "url-to-vm" {
  value = "${azurerm_public_ip.publicip.fqdn}"
}

resource "random_string" "name" {
  length  = 8
  special = false
  numeric  = false
  upper   = false
}

## <https://www.terraform.io/docs/providers/azurerm/r/resource_group.html>
resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = "westeurope"
}

## <https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html>
resource "azurerm_virtual_network" "vnet" {
  name                = "vNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## <https://www.terraform.io/docs/providers/azurerm/r/subnet.html> 
resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "publicip" {
    name                         = "${local.name_prefix}-PublicIP"
    domain_name_label             = "${local.name_prefix}-vm"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"

    tags = {
        environment = "Test"
    }
}

resource "azurerm_network_security_group" "example" {
  name                = "${local.name_prefix}-example-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "sshIn"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name         = azurerm_resource_group.rg.name
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "rdp" {
  name                        = "rdpIn"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name         = azurerm_resource_group.rg.name
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

## <https://www.terraform.io/docs/providers/azurerm/r/network_interface.html>
resource "azurerm_network_interface" "example" {
  name                = "${local.name_prefix}-nic-${local.name_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine>
resource "azurerm_linux_virtual_machine" "example" {
  name                = "${local.name_prefix}-vm-${local.name_suffix}"
  computer_name       = "${local.name_prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.VmSettings.size
  admin_username      = var.adminUsername
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  
  admin_ssh_key {
    username   = var.adminUsername
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.VmSettings.publisher
    offer     = var.VmSettings.offer
    sku       = var.VmSettings.sku
    version   = var.VmSettings.version
  } 
}