# How to upgrade the AzureRM Terraform provider

This repository serves as a companion to my [LinkedIn article](TODO), which discusses the necessary steps for performing a major version upgrade (including breaking changes to resource definitions) for Terraform infrastructure-as-code that utilizes the `azurerm` provider.

The repository's contents are organized as follows:

- `.github/workflows` - This directory houses the build and deployment pipeline responsible for deploying the application whenever changes are made to the content within the `src` directory.
- `blog` - This directory contains a Markdown representation of the actual LinkedIn article, including any accompanying images.
- `infrastructure` - This directory encompasses two subdirectories: `infrastructure/v2.99` and `infrastructure/v3.x`. The former contains the deprecated version of the infrastructure resource definition, while the latter contains the version to which the state will be upgraded.
- `src` - This directory contains a simple NodeJS application that serves the purpose of ensuring our app is up and running both before and after our migration.