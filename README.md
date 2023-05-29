# How to upgrade the AzureRM Terraform provider

This repository is a supplement to my LinkedIn article which discusses how to upgrade a the Terraform IaC, which backs an Azure environment, without needing to make drastic changes to the actual infrastructure; this includes migrating the contents of a state file stored in an Azure-driven backend.

The contents of the sub-directories are as follows:

- blog - This directory contains a Markdown representation of the actual LinkedIn article (along with any images used).
- infrastructure - This directory contains two subdirectories, `v2.99` and `v3.x`; the former containing the deprecated version of the infrastruture resource definition and the latter containing the version to which the state shall be upgraded.
- src - This directory contains a REALLY simply NodeJS application, which only provides a means of ensuring our app is up and running before and after our migration.