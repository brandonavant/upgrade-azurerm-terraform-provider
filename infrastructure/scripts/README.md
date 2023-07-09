# Useful Scripts

This sub-directory contains useful scripts for making the migration process easier:

| Script Name               | Description                                                  |
| ------------------------- | ------------------------------------------------------------ |
| get-azure-resource-ids.sh | This script will take a list of Terraform-controlled resources (indicated in the `terraform_ids` string array in the script) and output the corresponding fully-qualified Azure Resource Manager ID for the currently-deployed Azure resource. This is useful when making an inventory of all of the resources that will undergo a resource definition change and and as such will need a state file migration. |

