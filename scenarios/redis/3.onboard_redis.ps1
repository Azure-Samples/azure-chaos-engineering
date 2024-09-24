# Set the subscription ID and Azure resource group variables
. .\0.parameters.ps1

#Connect-AzAccount -Tenant $Tenant
#Set-AzContext -Subscription $SubscriptionId

az deployment group  create --resource-group   $resourceGroupName  --template-file "..\..\infra\bicep\redis_chaos\main.bicep" --parameters resourceGroupName=$resourceGroupName redisName=$redisName location=$Location 