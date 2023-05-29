# How to upgrade the AzureRM Terraform provider

This repository is intended as an accompaniment to my [LinkedIn article](TODO), which discusses the steps necessary to perform a major version upgrade (one that includes breaking changes to resource definitions) for infrastructure that uses the `azurerm` provider.

The contents of the sub-directories are as follows:

- `.github/workflows` - This directory contains the build and deployment pipeline for deploying the application when the `src` directory's content changes.
- `blog` - This directory contains a Markdown representation of the actual LinkedIn article (along with any images used).
- `infrastructure` - This directory contains two subdirectories, `v2.99` and `v3.x`; the former containing the deprecated version of the infrastruture resource definition and the latter containing the version to which the state shall be upgraded.
- `src` - This directory contains a REALLY simply NodeJS application, which only provides a means of ensuring our app is up and running before and after our migration.