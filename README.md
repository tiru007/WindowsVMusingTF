# WindowsVMusingTF

# terra-demo-vm
Deploy azure windows virtual machine using terraform
 - using existing VNET
 - from existing image
 - Creating availability set and adding VM to it.
 - updating VM after deployment.
 - Reading VM Password from AKV

# Next version
- Azure AD Domain Join
- Diagnostics logs to storage account
- other minor changes and adding tags.

# Steps to run
clone the repository
[https://github.com/tiru007/linuxVMusingTF] (https://github.com/tiru007/WindowsVMusingTF)

Browse to directory, where you have downloaded the repository

# Run terraform init to initialize the Terraform deployment. This command downloads the Azure modules required to manage your Azure resources.
> terraform init

# Run terraform plan to create an execution plan.
> terraform.exe plan -var-file="variables.tfvars" -out main.tfplan

# Run terraform apply to apply the execution plan to your cloud infrastructure.
> terraform apply main.tfplan

# Steps to Cleanup

# Run terraform plan and specify the destroy flag.
> terraform plan -destroy -var-file="variables.tfvars" -out main.destroy.tfplan

# Run terraform apply to apply the execution plan.
> terraform apply main.destroy.tfplan

Troubleshoot Terraform on Azure
> https://learn.microsoft.com/en-us/azure/developer/terraform/troubleshoot

Authenticate Terraform to Azure
> https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?source=recommendations&tabs=bash
