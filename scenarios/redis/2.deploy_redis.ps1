. .\0.parameters.ps1
# Login to Azure and set the context to the appropriate subscription
az account set --subscription $SubscriptionId

# Deploy AKS Cluster using Bicep file
Write-Output "Deploying Redis..."

az deployment group create --resource-group $ResourceGroupName --template-file "..\..\infra\bicep\redis\main.bicep" --parameters redisLocation=$Location  redisName=$redisName

