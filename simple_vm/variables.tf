variable "VmSettings" {
  description = "The Azure VM settings"
  default = {
    size       = "Standard_E4s_v3"
    sku        = "2019-datacenter-core-with-containers"
    version    = "17763.1158.2004131759"
    diskSizeGb = 250
  }
}

variable "Prefixes" {
  type = string
  default = "mytest" 
}

variable "adminUsername" {
  description = "The admin username for the VM"
  default     = "myuser"
}
