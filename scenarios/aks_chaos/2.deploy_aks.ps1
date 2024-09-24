. .\0.parameters.ps1
# Login to Azure and set the context to the appropriate subscription
az account set --subscription $SubscriptionId

# Deploy AKS Cluster using Bicep file
Write-Output "Deploying AKS Cluster..."

az deployment group create --resource-group $ResourceGroupName --template-file "..\..\infra\bicep\aks_cluster\main.bicep" --parameters location=$Location managedClusterName=$ClusterName resourceGroupName=$ResourceGroupName

# Install kubectl
az aks install-cli

# Get credentials for the new AKS cluster
az aks get-credentials --name $ClusterName --resource-group $ResourceGroupName