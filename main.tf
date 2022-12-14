terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.31.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = ""
  features {}

  skip_provider_registration = true
}

# Configure the Microsoft Azure Provider
# provider "azurerm" {
# subscription_id = "xxxx"
# client_id       = "xxxx"
# client_secret   = "xxxx"
# tenant_id       = "xxxx"

#  features {}
#  }

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
  name = var.existingVirtualNetworkName
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
    command     = <<EOT
       # "https://storagescrips.blob.core.windows.net/testcontainer/testlog.ps1"
         $logfilepath="D:\Log1.txt"
         $logmessage="This is a test message for the PowerShell create log file"
         if(Test-Path $logfilepath)
         {
            Remove-Item $logfilepath
         }
         $logmessage +" - "+ (Get-Date).ToString() >> $logfilepath
     EOT
    interpreter = ["powershell", "-Command"]
  }
  depends_on = [
    azurerm_windows_virtual_machine.example
  ]
}

#data "azurerm_key_vault" "example" {
#  name                = "tiruakv"
#  resource_group_name = "tirunetwork"
#}

#data "azurerm_key_vault_secret" "test" {
#  name         = "vmpassword"
#  key_vault_id = data.azurerm_key_vault.example.id

  # vault_uri is deprecated in latest azurerm, use key_vault_id instead.
  # vault_uri = "https://mykeyvault.vault.azure.net/"
#}

resource "azurerm_managed_disk" "example" {
  name                 = "${var.vmname}-disk1"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_windows_virtual_machine.example.id
  lun                = "10"
  caching            = "ReadWrite"
}

data "template_file" "tf" {
  template = file("FormatDisk.ps1")
}

resource "azurerm_virtual_machine_extension" "disk_init" {
  name                 = "vm-disk-init-ext"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
          "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf.rendered)}')) | Out-File -filepath FormatDisk.ps1\" && powershell -ExecutionPolicy Unrestricted -File FormatDisk.ps1"
    }
SETTINGS

  tags = var.tags
}

# output "secret_value" {
#   value = "${data.azurerm_key_vault_secret.test.value}"
# }