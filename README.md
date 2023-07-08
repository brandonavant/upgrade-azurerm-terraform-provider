# How to upgrade the AzureRM Terraform provider

This repository serves as a companion to my [LinkedIn article](TODO), which discusses the necessary steps for performing a major version upgrade (including breaking changes to resource definitions) for Terraform infrastructure-as-code that utilizes the `azurerm` provider.

The repository's contents are organized as follows:

- `.github/workflows` - This directory houses the build and deployment pipeline responsible for deploying the application whenever changes are made to the content within the `src` directory.
- `blog` - This directory contains a Markdown representation of the actual LinkedIn article, including any accompanying images.
- `infrastructure` - This directory encompasses two subdirectories: `infrastructure/v2.99` and `infrastructure/v3.x`. The former contains the deprecated version of the infrastructure resource definition, while the latter contains the version to which the state will be upgraded.
- `src` - This directory contains a simple NodeJS application that serves the purpose of ensuring our app is up and running both before and after our migration.

## How to use demo

If you would like to use the files outline in this repo as a means of practicing the concepts introduced, please utilize the following steps:

### Create the backend storage account

First, manually (using the Azure portal) create a resource group called `rg-azurerm-upgrade-demo-tfstate`. Inside the resource group, create a storage account called `stazurermupgradetfstate`.

The reason why we create this resource group and the underlying storage account manually is that it is where the Terraform state file will be stored in Azure. For more information about this practice, please read the [official documentation](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) on the topic.

> Note: Alternatively, you could forgo using the `backend` resource and instead store the state locally. You could also use a managed state management option like [Terraform Cloud](https://www.terraform.io/).

### Initialize the state

Once the storage account is in place, navigate via the command-line to the directory in which the v2.99 files exist and run this command:

```bash
terraform init
```

Assuming everything is in place, the Terraform CLI will configure the state file in the Azure storage account and provide feedback as to when it is complete. You can then proceed with building the actual infrastructure.

### Deploying our infrastructure

We are now ready to build out the infrastructure in Azure. We start by running a plan to see what Terraform will create:

```bash
terraform plan
```

The feedback from this command should indicate its plan to create the following resources:

- asp-azurerm-upgrade-demo - An App Service Plan which acts as the parent configuration for applications hosted on Azure, in this case that is our demo Node app.
- app-azurerm-upgrade-demo - An App Service instance which shall host our demo Node application.
- rg-azurerm-upgrade-demo - A resource group which will house all of the aforentioned resources, allowing us to group them under one unit, which can be easily identified in billing and deleted as a group when necessary.

If you're okay with the outlined plan, run this command:

```bash
terraform apply
```

This command will run the same plan but now present you with the option to actually put it into action. If you agree with the plan, respond to the prompt accordingly.

At this point, we are finished with the setup. You can now proceed with the steps outlined in the [LinkedIn article](TODO). Please use the files in the `infrastructure/v3.x` directory when following along.

Happy migrating!
