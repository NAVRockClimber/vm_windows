variable "Azure" {
  description = "The Azure settings like the tenant to be used"
  default = {
    tenant_id = "b281b732-74b8-40b0-b77e-66469839832e"
    subscription_id = "6e044f76-236a-4cc9-a663-601117f111a1"
  }
}

variable "VmSettings" {
  description = "The Azure VM settings"
  default = {
    size       = "Standard_E4s_v3"
    publisher = "Canonical"
    offer      = "0001-com-ubuntu-server-jammy"
    sku        = "22_04-lts-gen2"
    version    = "latest"
    diskSizeGb = 250
  }
}

variable "Prefixes" {
  type = string
  default = "bxdemo" 
}

variable "adminUsername" {
  description = "The admin username for the VM"
  default     = "myuser"
}
