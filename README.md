# My personal terraform templates

Just a collection of my personal terraform templates. Do it once, do it twice manually and then automate it.

## General Usage

If it makes sense a variable file is added to the templates where resource names, sizes or similar is configured.

Before you start consult the [terraform documentation](https://www.terraform.io/docs/cli/index.html). 

If you use a template run **once**:

``` Powershell
az login
az account set --subscription="..."
terraform init
```

To test run without deployment run:
``` Powershell
terraform plan
```

To deploy resource run:
``` Powershell
terraform apply
```

To delete resources run:
``` Powershell
terraform destroy
```

If possible passwords are generated. Currently Terrform became an update where sensitive information is not printed out anymore.
To get the password run:
``` Powershell
terraform output -json
```

Example:
``` Terraform
variable "VmSettings" {
  description = "The Azure VM settings"
  default = {
    size       = "Standard_E4s_v3"
    sku        = "2019-datacenter-core-with-containers"
    version    = "17763.1158.2004131759"
    diskSizeGb = 250
  }
}

locals {
  name = "my test" // replace me
}

variable "adminUsername" {
  description = "The admin username for the VM"
  default     = "myuser" // replace me
}
```

## Deploy a test VM in Azure


