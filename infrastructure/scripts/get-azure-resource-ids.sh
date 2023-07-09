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