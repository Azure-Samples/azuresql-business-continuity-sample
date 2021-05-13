# Azure SQL Database Business Continuity

Azure SQL is a database as a service and a popular service on Azure, it also has the feature to support Business Continuity enabling the business to continue operating in the face of disruption particularly to its computing infrastructure. This sample includes a set of deployment resources to setup a BCDR environment with SQL Azure, and the scripts to failover and failback.

## Features

This project provides the following features:

* ARM template to deploy primary and secondary Azure SQL servers with the networks configured.
* The script to switch failover and failback between the primary and secondary environment.

## Getting Started

### Prerequisites

- An active Azure Subscription
- Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Quickstart

1. Clone this repository 
2. Update the values of ARM parameters in arm-deployment/*.parameters.json files
3. Define the configuration values as the environment variables for using in bash script
  ```
    #configure primary resource group's name
    primary_rg=primary_resource_group

    #configure primary region
    primary_region=[replace_with_region_name]
    
    #primary Azure SQL server name
    primary_sqlserver_name=[replace_with_primary_sqlserver_name]
  ```
4. Provision Azure resources in the primary environment by running in bash
  ```
    #create resource group with az cli.
    az group create -n $primary_rg --location $primary_region
    
    #deploy with az cli to primary resource group
    az deployment group create --name deployment-name --resource-group $primary_rg --template-file arm-deployment/azuredeploy.json --parameters arm-deployment/azuredeploy.parameters.json --parameters serverName=$primary_sqlserver_name
  ```
5. Define the configuration values as the environment variables for the secondary environment
  ```
    #run the script to get paired region of the primary region
    source ./scripts/azcli-preparation.sh $primary_rg

    #set secondary resource group name
    secondary_rg=[replace_with_secondary_resourcegroup_name]

    #set secondary Azure region
    secondary_region=$pairedRegion
    #or 
    secondary_region=[replace_with_secondary_region]

    #set sql server name
    sqlazure_secondary_instance_name=[replace_with_secondary_sqlserver_name]
  ```
6. Provision Azure resources in the secondary environment
  ```
    #create the resource group to deploy the secondary environment.
    az group create -n $secondary_rg --location $secondary_region
    
    #deploy the secondary environment, and get the output of failover group name to continue.
    fog_name=$(az deployment group create --name sqlmisecondary --resource-group $secondary_rg --template-file arm-deployment/azuredeploy.json --parameters arm-deployment/azuredeploy.parameters.json --parameters serverName=$sqlazure_secondary_instance_name addressSpace=10.1.0.0 primaryResourceGroup=$primary_rg primaryServerName=$primary_sqlserver_name --query properties.outputs.sqlazurefogname.value)
  ```
8. Remove double quote of fog_name variable to get failover group name correctly
  ```
    #remove double quotes (“) from fog_name
    fog_name="${fog_name%\"}"
    fog_name="${fog_name#\"}"
  ```
10. Use fog_name to run failover and failback


## Demo

After completing environment setup, you can run the scripts below to failover and failback the environment.

1. Failover (switch from the primary to the secondary)
  ```
    ./scripts/failover.sh $fog_name $secondary_rg $sqlazure_secondary_instance_name
  ```
2. Failback
  ```
    ./scripts/failover.sh $fog_name $primary_rg $primary_sqlserver_name
  ```

## Resources

- [SQL Azure failover groups](https://docs.microsoft.com/en-us/azure/azure-sql/database/auto-failover-group-overview?tabs=azure-powershell)
