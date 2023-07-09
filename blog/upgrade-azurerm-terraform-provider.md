# Effortless Terraform Migration: Upgrading Azure Resource Definitions to Terraform AzureRM 3.x

When navigating the Terraform documentation for AzureRM resource definitions, you may have noticed that some of the resource pages now greet users with messages similar to the following:

> *"This resource has been deprecated in version 3.0 of the AzureRM provider and will be removed in version 4.0. Please use [`azurerm_linux_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) and [`azurerm_windows_function_app`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) resources instead."*

That particular message is a result of visiting the documentation page for the now deprecated [azurerm_function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app) resource. Well, what exacty does this mean? It means a few different things, most important of which is that starting in version 4.0 of the AzureRM that resource definition (and several others) will cease to exist. This will block you and your team from being able to use newer versions of the provider, which can cause problems in organizations' development cycles.

To avoid this problem, it is best to upgrade your resource definitions sooner rather than later. In this article, I am going to show you how!

> Note: If you want to practice the concepts that I've introduced here, I've built a complete demo project (which includes a deployable Node application). You can find the project, all of the ncessary terraform scripts, etc. in my [GitHub repository here](https://github.com/brandonavant/upgrade-azurerm-terraform-provider).

## Prerequisites

Before we get started, there are a few prerequisites:

- Ensure that you are running the latest version of the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform).
- This article assumes that you have a basic working knowledge of the Terraform CLI, including state file basics (e.g. understanding what `terraform init` does).
- It is assumed that you already have infrastructure setup in Azure and wish to perform a provider upgrade. That said, I will not be covering the specifics of how to get infrastructure deployed to Azure.

## Understanding What Should Be Upgraded

Before we can perform the actual migration, we should gain an understanding of what resource definitions were deprecated and must be upgraded. As of the writing of this article, the list is as follows:

- **azurerm_app_service_active_slot** is replaced by **azurerm_function_app_active_slot** for both Linux and Windows based Function Apps.
- **azurerm_app_service_hybrid_connection** is replaced by **azurerm_function_app_hybrid_connection** for Hybrid Connections on Linux and Windows based Web Apps.
- **azurerm_function_app** is replaced by **azurerm_linux_function_app** for Linux-based Function Apps.
- **azurerm_function_app_slot** is replaced by **azurerm_linux_function_app_slot** for Deployment Slots on Linux-based Function Apps.
- **azurerm_app_service** is replaced by **azurerm_linux_web_app** for Linux-based Web Apps.
- **azurerm_app_service_slot** is replaced by **azurerm_linux_web_app_slot** for Deployment Slots on Linux-based Web Apps.
- **azurerm_app_service_plan** is replaced by **azurerm_service_plan**.
- **azurerm_app_service_source_control_token** is replaced by **azurerm_source_control_token**.
- **azurerm_app_service_active_slot** is replaced by **azurerm_web_app_active_slot** for both Linux and Windows based Web Apps.
- **azurerm_app_service_hybrid_connection** is replaced by **azurerm_web_app_hybrid_connection** for Hybrid Connections on Linux and Windows based Web Apps.
- **azurerm_function_app** is replaced by **azurerm_windows_function_app** for Windows-based Function Apps.
- **azurerm_function_app_slot** is replaced by **azurerm_windows_function_app_slot** for Deployment Slots on Windows-based Function Apps.
- **azurerm_app_service** is replaced by **azurerm_windows_web_app** for Windows-based Web Apps.
- **azurerm_app_service_slot** is replaced by **azurerm_windows_web_app_slot** for Deployment Slots on Windows-based Web Apps.

> Note: Please consult the [official guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-upgrade-guide) for more information and a potentially more up-to-date list.Make An Upgrade Inventory

Now that you understand which resource definitions are affected, you will need to make a record of the fully-qualified Azure Resource Manager IDs for each of the resources that you've deployed into Azure using these deprecated resource definitions. **It is important that you make this list now as it will be more tedious to get this list as we proceed further into the migration steps.**

I have prepared a Bash script that will retrieve this list for you:

> Note: You may need to install `jq`. On macOS, you can do this by running `brew install jq`.

```bash
#!/bin/bash

# Check if the directory path argument is provided
if [ -z "$1" ]; then
  echo "Please provide a relative path to the Terraform script (e.g. ../v2.99) as an argument."
  exit 1
fi

cd "$1" # Set the working directory

# Replace the strings in array below with your Terraform resource ids. Separate each string by a space.
terraform_ids=("azurerm_app_service.app" "azurerm_app_service_plan.plan")
terraform_show_output=$(terraform show -json)

# Loop through each Terraform ID
for id in "${terraform_ids[@]}"
do
  # Get the Azure resource ID using the Terraform CLI
  resource_id=$(echo "$terraform_show_output" | jq -r '.values.root_module.resources[] | select(.address == "'${id}'") | .values.id')

  # Print the Terraform ID and corresponding Azure resource ID
  echo "Terraform ID: $id"
  echo "Azure Resource ID: $resource_id"
  echo "-----------------------------------"
done
```

All that you will need to do to prepare this script is to update the strings in the `terraform_ids` array (found on line 12) with your fully-qualified terraform ids.

For example, consider the following resource definition:

```hcl
resource "azurerm_app_service" "app" {
  name                = "app-azurerm-upgrade-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|lts"
  }

  tags = {
    "createdBy" = "Terraform"
  }
}
```

In this scenario, you would add `azurerm_app_service.app` to the string array (as demonstrated in one of the two placeholder strings in the provided script). After running the script, you should receive a list similar to the following:

```bash
Terraform ID: azurerm_app_service.app
Azure Resource ID: /subscriptions/<subscription-id>/resourceGroups/rg-azurerm-upgrade-demo/providers/Microsoft.Web/sites/app-azurerm-upgrade-demo
-----------------------------------
Terraform ID: azurerm_app_service_plan.plan
Azure Resource ID: /subscriptions/<subscription-id>/resourceGroups/rg-azurerm-upgrade-demo/providers/Microsoft.Web/serverfarms/asp-azurerm-upgrade-demo
```

Keep a record of all of the values that this gives you as you will need them later.

## Executing The Migration

We are now ready to begin the migration process. Migrating from v2.x to v3.x of the AzureRM provider consist of the following steps:

1. Performing a back-up of your state file.
2. Updating the configuration to point to the newest version of the AzureRM provider and re-initializing the lock file.
3. Upgrading each of the deprecated resource definition.
4. Updating the state file to map the new resource definitions to the existing infrastructure.


