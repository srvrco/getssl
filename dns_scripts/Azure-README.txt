Using Azure for LetsEncrypt domain verification

Guide for using Azure for LetsEncrypt domain verification.

Prerequisites:
- Azure CLI tools installed - see https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Logged in with azure-cli - i.e. azure login

The dns_add_azure and dns_del_azure scripts assume that the following
environment variables are added to the configuration file:

- AZURE_RESOURCE_GROUP - the name of the resource group that contains the DNS zone 
- AZURE_ZONE_ID - the name of the DNS zone 
- AZURE_SUBSCRIPTION_ID - the name or ID of the subscription that AZURE_RESOURCE_GROUP is part of

Each of these variables can be included in the .getssl.cfg, e.g:

export AZURE_RESOURCE_GROUP=my-resource-group
export AZURE_ZONE_ID=example.com
export AZURE_SUBSCRIPTION_ID=my-azure-subscriptin 

