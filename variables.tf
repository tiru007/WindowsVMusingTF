variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "myResourceGroup"
}

variable "location" {
  default     = "eastus"
  description = "Location where resources will be created"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "codelab"
  }
}

variable "vmSize" {
  description = "size of the vm"
}

# variable "managedImageResourceGroupName" {
#    description = "name of the managedImageResourceGroup"
# }

variable "AvailabilitySetName" {
  description = "name of existing AvailabilitySet"
}

# variable "managedImageName" {
#    description = "name of the managedImage"
# }

variable "vmname" {
  description = "name of the VM"
}

variable "subnetName" {
  description = "subnet where the virtual machine resides"
}

variable "existingVirtualNetworkName" {
  description = "name of the existing Virtual Network Name"
}

variable "existingVirtualNetworkResourceGroupName" {
  description = "name of the existing Virtual Network RG Name"
}

variable "username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

#variable "password" {
#  description = "Default password for admin account"
#}

# variable "fileUris" {
#   description = "fileUris for post processing"
# }