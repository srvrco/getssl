Using Azure for LetsEncrypt domain verification

Guide for using Azure for LetsEncrypt domain verification.

Prerequisites:
- Azure CLI tools installed - see https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Logged in with azure-cli - i.e. azure login

Ensure dns_add_azure and dns_del_azure scripts are called when the DNS is validated by modifying the .getssl.cfg:

VALIDATE_VIA_DNS=true
DNS_ADD_COMMAND=dns_scripts/dns_add_azure # n.b use valid path
DNS_DEL_COMMAND=dns_scripts/dns_del_azure

The dns_add_azure and dns_del_azure scripts assume that the following environment variables are added to the configuration file:

- AZURE_RESOURCE_GROUP - the name of the resource group that contains the DNS zone 
- AZURE_ZONE_ID - a comma-separated list of valid DNS zones. this allows the same certificate to be used across multiple top-level domains
- AZURE_SUBSCRIPTION_ID - the name or ID of the subscription that AZURE_RESOURCE_GROUP is part of

Each of these variables can be included in the .getssl.cfg, e.g:

export AZURE_RESOURCE_GROUP=my-resource-group
export AZURE_ZONE_ID=example.com,anotherdomain.com
export AZURE_SUBSCRIPTION_ID=my-azure-subscriptin 

