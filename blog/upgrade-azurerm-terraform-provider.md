# Effortless Migration: Upgrading Azure Resource Definitions with Terraform AzureRM 3.x

TL;DR: When you install your Azure infrastructure using Terraform, there are instances in which it is imperative that you migrate soon-to-be obsolete resource definitions over to the up-to-date versions. To do this, you must do the following (at a high-level):

1. Read the official documentation to understand which resources have changed and how.
1. Store your existing resources' resource ids somewhere to be referenced later.
1. Update your AzureRM provider's version.
1. Update each of the resource definitions to the new format.
1. Remove the old resource definition name references from your state file.
1. Import the existing resource ids, using the new resource definition names.
1. Validate that nothing significant changed.

# Prerequisites

- Latest version of the Terraform CLI
- Basic Terraform knowledge
- An existing Azure account for which you have the appropriate permissions to perform the tasks detailed in this article.

# Setup

## Environment Variables

Although we *could* perform an `az login` to authenticate our subsequent `terraform` commands, I prefer to simulate how things will run when a build agents runs the deployments using the service principal's credentials. That said, let's explicitly use those credentials.

First, perform an `az logout` to logout of *your* credentials. Next, add the following environment variables to the corresponding location for your operating system. I am using Ubuntu, so I would do a `vim ~/.bashrc` and add the following:

`