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

Now that you understand which resource definitions are affected, you will need to make a record of the fully-qualified Azure Resource Manager IDs for each of the resources that you've deployed into Azure using these deprecated resource definitions. **It is important that you make this list *now* as it will be more tedious to get this list as we proceed further into the migration steps.**

I have prepared a Bash script that will retrieve this list for you. It takes a single parameter, which is the relative path to the directory that contains your Terraform files. For example, `./script.sh ../path/to/terraform/files`.

> Note: You may receive errors about `jq`not being recognized. If so, you need to install it. On macOS, you can do this by running `brew install jq`.

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

All that you will need to do to prepare this script is to update the strings in the `terraform_ids` array (found on line 12) with your fully-qualified terraform ids. For example, consider the following resource definition:

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

### Backup State File

If there is a problem during the migration process, we might need to roll back our changes. The quickest way to roll back the changes is to restore the state file to the original state. To ensure that this will be possible, we will need to perform a backup.

Going with the assumption that we've stored our state file in an Azure Storage account, we will need to perform the following steps:

Using the Azure portal, navigate to the Azure Storage account in which the state file is stored.

![Storage Account](/Users/programmerx-mbp2/Source/Repos/upgrade-azurerm-terraform-provider/blog/images/storage.png)

Next, navigate to the container (e.g. `tfstate`).

![Container](/Users/programmerx-mbp2/Source/Repos/upgrade-azurerm-terraform-provider/blog/images/container.png)

Click the *Snapshots* tab shown on this page and then click *Create Snapshot*.

![Snapshot](/Users/programmerx-mbp2/Source/Repos/upgrade-azurerm-terraform-provider/blog/images/snapshot.png)

You should now see a snapshot of your state file. We could then promote this later, if we needed to restore the state. That's it!

### Upgrade Provider

Now that we've made a snapshot/backup of our state file, we can proceed with the upgrade. The first thing we will need to do is actually upgrade the provider version to 3.x. To do this, modify your `terraform.required_providers` block to use the latest 3.x version of the AzureRM provider. Your updated block should look similar to this:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

	...
}

provider "azurerm" {
  features {
  }
}
```

Notice the `version = "~> 3.0"`, which simply contrains our version with the 3.x range of provider versions. Now run the following command to update the lock file to match the new version.

```bash
terraform init -upgrade
```

You should receive output similar to the following:

```bash
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 3.0"...
- Installing hashicorp/azurerm v3.64.0...
- Installed hashicorp/azurerm v3.64.0 (signed by HashiCorp)

...
```

If so, that means this step is complete. We can now move on updating each of the resource definitions to their successor definition.

### Update Resource Definitions

Now that we've updated the AzureRM provider version, let's run another `terraform plan` to see what it now shows. You *should* see output similar to the following:

```bash
azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/<subscription-id>/resourceGroups/rg-azurerm-upgrade-demo]
azurerm_app_service_plan.plan: Refreshing state... [id=/subscriptions/<subscription-id>/resourceGroups/rg-azurerm-upgrade-demo/providers/Microsoft.Web/serverfarms/asp-azurerm-upgrade-demo]
azurerm_app_service.app: Refreshing state... [id=/subscriptions/<subscription-id>/resourceGroups/rg-azurerm-upgrade-demo/providers/Microsoft.Web/sites/app-azurerm-upgrade-demo]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
╷
│ Warning: Deprecated Resource
│ 
│   with azurerm_app_service.app,
│   on appsvc.tf line 1, in resource "azurerm_app_service" "app":
│    1: resource "azurerm_app_service" "app" {
│ 
│ The `azurerm_app_service` resource has been superseded by the `azurerm_linux_web_app` and `azurerm_windows_web_app` resources. Whilst this resource will continue
│ to be available in the 2.x and 3.x releases it is feature-frozen for compatibility purposes, will no longer receive any updates and will be removed in a future
│ major release of the Azure Provider.
│ 
│ (and 3 more similar warnings elsewhere)
```

Let's break down each block of information in the output and what it is telling us.

```bash
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

The first thing that it tells us is that there are no changes being made to the infrastructure. This is what we want. In subsequent steps, we *might* see *some* changes, but they should be minor changes that are a result of new fields that didn't exist before or fields whose default values were changed.

Next,

```bash
╷
│ Warning: Deprecated Resource
│ 
│   with azurerm_app_service.app,
│   on appsvc.tf line 1, in resource "azurerm_app_service" "app":
│    1: resource "azurerm_app_service" "app" {
│ 
│ The `azurerm_app_service` resource has been superseded by the `azurerm_linux_web_app` and `azurerm_windows_web_app` resources. Whilst this resource will continue
│ to be available in the 2.x and 3.x releases it is feature-frozen for compatibility purposes, will no longer receive any updates and will be removed in a future
│ major release of the Azure Provider.
│ 
│ (and 3 more similar warnings elsewhere)
```

**This** is the portion of the output that is most important to use. What it's telling us is that our current infrastructure components are using deprecated Terraform resource definitions. This is what we expect and is what we are fixing.

The warnings seem to show one at a time (notice the `(and 3 more similar warnings elsewhere)`) and as we fix one, we can re-run `terraform plan` to see the next warning. We can use this mechanism to double check our work and ensure that we didn't miss anything when we made our inventory [back in earlier steps](#understanding-what-should-be-upgraded).

Let's keep this in mind as we're executing the next step...

Now, the most tedious part. We must go through *each* of the resource definitions that we identified as deprecated and migrate the resource to the most up-to-date equivalent. While the [Official Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-upgrade-guide) does outline many of the changes (CMD+F / CTRL+F is your friend), I did find in my experiences that the guide did miss some things. It's best to be thorough and visit the documentation for each of the successor resource definitions. Also, your IDE's autocomplete/IntelliSense, should help as well.

> Note: I wasn't a big fan of the experience that I had using the official Terraform plugin (from HashiCorp) for VSCode. I found that the plugin available in the Jet Brains IDEs (e.g. Rider) was much more helpful.

So, for example, consider the deprecated resource definition `azurerm_app_service_plan`. For this, we might have the following:

```hcl
resource "azurerm_app_service_plan" "plan" {
    name = "asp-azurerm-upgrade-demo"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    kind = "Linux"
    reserved = true
    
    sku {
        tier = "Standard"
        size = "S1"
    }

    tags = {
      "createdBy" = "Terraform"
    }
}
```

Per the documentation, we need to convert this to use `azurerm_service_plan`; like so:

![Diff](/Users/programmerx-mbp2/Source/Repos/upgrade-azurerm-terraform-provider/blog/images/diff.png)

Notice that these aren't one-to-one. That said, pay close attention to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) and use `terraform validate` to check your work. You will need to follow these steps for each of the resource definitions that you are updating. 

Unfortunately, I can't exhaustively cover all of the possibilities here, so again, it's super important to lean on the documentation.

