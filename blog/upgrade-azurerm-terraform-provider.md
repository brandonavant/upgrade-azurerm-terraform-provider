# Effortless Terraform Migration: Upgrading Azure Resource Definitions to Terraform AzureRM 3.x

When you install your Azure infrastructure using Terraform, there are instances in which it is imperative that you migrate soon-to-be-obsolete resource definitions over to the up-to-date versions. 

For example,

In this article, I will illustrate (using one of the most classic examples) how to upgrade your resource definitions and state file in such a way where you won't have to do a complete tear-down and re-build of your infrastructure.

# Prerequisites

Before we get started, there are a few prerequisites:

- Ensure that you are running the latest version of the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform).
- This article assumes that you have a basic working knowledge of the Terraform CLI, including state file basics (e.g. understanding what `terraform init` does).
- It is assumed that you already have infrastructure setup in Azure and wish to perform a provider upgrade. That said, I will not be covering the specifics of how to get infrastructure deployed to Azure.

# Setup

Prior to jumping into the actual migration, there is a bit of setup work that we should lead with.

## Environment Variables

> Note: You can skip this step if you prefer to use your `az login`-provided authentication.

We *could* perform an `az login` to authenticate the subsequent `terraform` commands; however, I prefer to simulate how things will run when a deployment agent runs, using the service principal's credentials. This allows us to catch any potential issues that might occur when the agent runs in production.

All that said, let's setup the appropriate environment variables.

First, perform an `az logout` to log out of *your* credentials. Next, add the following environment variables to the corresponding location for your operating system. I am using macOS, so I would do a `vim ~/.zshrc` and add the following:

```bash
export ARM_CLIENT_ID="<service-principal-client-id>"
export ARM_CLIENT_SECRET="<service-principal-client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-where-infrastructure-is-deployed>"
export ARM_TENANT_ID="<your-tenant-id>"
```

## Determine which resources need migrating

Prior to actually performing the migration, we will need to determine *which* resources actually need to be migrated. Luckily, the Terraform CLI will aid us in making such a determination.

> Reminder: Please ensure that your Terraform CLI is using the most up-to-date version. Using an old version of the CLI may not provide the feedback describe below.

Using the Terraform CLI, run a plan in the directory where your terraform scripts reside:

```bash
terraform plan
```

This *should* present you with feedback similar to the following:

```bash
TODO: Fill this out
```

As you can see, there are warnings for each of the deprecated resource definitions. These are the resource definitions that will need to be updated. To help document things, and prepare you plan for your migration, I recommend making a table similar to the following:

| Resource Name | Old Resource Definition | New Resource Definition |
| ------------- | ----------------------- | ----------------------- |
|               |                         |                         |
|               |                         |                         |

# The Migration

## Get the ARM Resource IDs

Prior to updating our Terraform scripts to use the new resource names, we need make a note of what the Azure Resource Manager IDs are for the existing resources (those already out in Azure). We will need this in subsequent steps.

To do this, we can use the following bash shell script. You will need to run it in the directory in which your `.tf` scripts exist:

```bash
#!/bin/bash

# Check if the directory path argument is provided
if [ -z "$1" ]; then
  echo "Please provide a relative path to the Terraform script (e.g. ../v2.99) as an argument."
  exit 1
fi

cd "$1" # Set the working directory

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

The output will be similar to the following:

```bash
Terraform ID: azurerm_app_service.app
Azure Resource ID: /subscriptions/<your-subscription-id>/resourceGroups/rg-azurerm-upgrade-demo/providers/Microsoft.Web/sites/app-azurerm-upgrade-demo
```

You will receive that output for each of the resources that you are migrating.