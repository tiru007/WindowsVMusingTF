# provider "azurerm" {
#  features {}
# }

# Configure the Microsoft Azure Provider
provider "azurerm" {
    # subscription_id = "xxxx"
    # client_id       = "xxxx"
    # client_secret   = "xxxx"
    # tenant_id       = "xxxx"

    features {}
}

# Locate the existing custom/golden image
# data "azurerm_image" "search" {
#  name                = var.managedImage
#  resource_group_name = var.managedImageResourceGroup
# }

# output "image_id" {
#   value = "/subscriptions/xxxxxx/resourceGroups/RG-EASTUS-SPT-PLATFORM/providers/Microsoft.Compute/images/AZLXDEVOPS01_Image"
# }

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_availability_set" "example" {
  name                = var.AvailabilitySetName
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    environment = "Production"
  }
}

data "azurerm_virtual_network" "example" {
  name                = var.existingVirtualNetworkName
  # address_space       = ["10.0.0.0/16"]
  # location            = azurerm_resource_group.example.location
  resource_group_name = var.existingVirtualNetworkResourceGroupName
}

resource "azurerm_subnet" "example" {
  name                 = var.subnetName
  resource_group_name  = var.existingVirtualNetworkResourceGroupName
  virtual_network_name = var.existingVirtualNetworkName
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = azurerm_subnet.example.name
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = var.vmname
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  availability_set_id = azurerm_availability_set.example.id
  size                = var.vmSize
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # storage_image_reference {
  #  id = "${data.azurerm_image.search.id}"
  # }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "null_resource" "example" {
    provisioner "local-exec" {
      command = <<EOT
        fileUris = var.fileUris
        powershell -ExecutionPolicy Unrestricted -File appinstall.ps1
      EOT
    interpreter = ["powershell", "-Command"]
    }
  depends_on = [
    azurerm_linux_virtual_machine.example
  ]
}