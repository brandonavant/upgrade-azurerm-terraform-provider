# How to Upgrade the AzureRM Terraform Provider

This repository serves as a companion to my [LinkedIn Article](https://www.linkedin.com/pulse/effortless-terraform-migration-upgrading-resource-version-avant), which discusses the necessary steps for performing a major version upgrade (including breaking changes to resource definitions) for Terraform infrastructure-as-code that utilizes the `azurerm` provider.

The repository's contents are organized as follows:

- [.github/workflows](/.github/workflows) - This directory houses the build and deployment pipeline responsible for deploying the application whenever changes are made to the content within the `src` directory.
- [blog](/blog/) - This directory contains a Markdown representation of the actual LinkedIn article, including any accompanying images.
- [infrastructure](/infrastructure/) - This directory encompasses two subdirectories: [v2.99](/infrastructure/v2.99/) and [v3.x](/infrastructure/v3.x/). The former contains the deprecated version of the infrastructure resource definition, while the latter contains the version to which the state will be upgraded.
- [src](/src/) - This directory contains a simple NodeJS application that serves the purpose of ensuring our app is up and running both before and after our migration.

## How to Use the Demo

If you would like to use the files outlined in this repo as a means of practicing the concepts introduced, please follow these steps:

### Create the Backend Storage Account

First, manually create a resource group called `rg-azurerm-upgrade-demo-tfstate` using the Azure portal. Inside the resource group, create a storage account called `stazurermupgradetfstate`.

We create this resource group and the underlying storage account manually because it is where the Terraform state file will be stored in Azure. For more information about this practice, please read the [official documentation](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) on the topic.

> Note: Alternatively, you could forgo using the `backend` resource and instead store the state locally. You could also use a managed state management option like [Terraform Cloud](https://www.terraform.io/).

### Initialize the State

Once the storage account is in place, navigate via the command-line to the directory where the v2.99 files exist and run the following command:

```bash
terraform init
```

Assuming everything is in place, the Terraform CLI will configure the state file in the Azure storage account and provide feedback as to when it is complete. You can then proceed with building the actual infrastructure.

### Deploying Our Infrastructure

We are now ready to build out the infrastructure in Azure. Start by running a plan to see what Terraform will create:

```bash
terraform plan
```

The feedback from this command should indicate its plan to create the following resources:

- `asp-azurerm-upgrade-demo` - An App Service Plan that acts as the parent configuration for applications hosted on Azure, in this case, our demo Node app.
- `app-azurerm-upgrade-demo` - An App Service instance that will host our demo Node application.
- `rg-azurerm-upgrade-demo` - A resource group that will house all of the aforementioned resources, allowing us to group them under one unit, which can be easily identified in billing and deleted as a group when necessary.

If you're okay with the outlined plan, run this command:

```bash
terraform apply
```

This command will run the same plan but now present you with the option to actually put it into action. If you agree with the plan, respond to the prompt accordingly.

### Deploying the Application

To have an application running within the Azure App Service instance, you can use the Node application found in the [src](/src/) directory. The [workflows](/.github/workflows) directory also contains a GitHub Action definition for deploying the application to Azure. To keep this demonstration simple and focused, I will not provide details here on how to perform CI/CD to deploy the applications. For an overview, please read the comments found at the top of [azure-webapps-node.yml](/.github/workflows/azure-webapps-node.yml).

At this point, we are finished with the setup. You can now proceed with the steps outlined in the [LinkedIn article](TODO). Please use the files in the [infrastructure/v3.x](/infrastructure/v3.x/) directory when following along.

Happy migrating!
