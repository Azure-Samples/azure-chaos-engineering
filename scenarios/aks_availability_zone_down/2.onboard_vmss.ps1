. .\0.parameters.ps1

az account set --subscription $SubscriptionId

# Generate a name for the managed identity
$identityName = $clusterName + "-mi"

# Create a managed identity
Write-Host "Creating Managed Identity '$identityName' in resource group '$resourceGroupName'..."
$identity = az identity create --name $identityName --resource-group $resourceGroupName --location $Location --output json | ConvertFrom-Json

Write-Host "Managed identity created with ID: $($identity.id)"

# Retrieve the AKS cluster details to find the node resource group
Write-Host "Retrieving AKS cluster details for '$clusterName'..."
$aksClusterDetails = az aks show --name $clusterName --resource-group $resourceGroupName --output json | ConvertFrom-Json
$nodeResourceGroup = $aksClusterDetails.nodeResourceGroup

# List all VMSS in the node resource group and find the VMSS for the agent pool
Write-Host "Retrieving VMSS list from node resource group '$nodeResourceGroup'..."
$vmssList = az vmss list --resource-group $nodeResourceGroup --output json | ConvertFrom-Json

# Extract and display the VMSS names
$foundVmssNames = $vmssList | ForEach-Object { $_.name }
if ($foundVmssNames.Length -gt 0) {
    Write-Host "VMSS names found in node resource group '$nodeResourceGroup':"
    $foundVmssNames | ForEach-Object { Write-Host $_ }
}
else {
    Write-Host "No VMSS found in node resource group '$nodeResourceGroup'."
}

Start-Sleep 30
# Assign 'Contributor' role to the managed identity for the AKS resource group
$roleName = "Contributor"
$identityPrincipalId = $identity.principalId

Write-Host "Assigning role '$roleName' to managed identity '$identityName' for the resource group '$resourceGroupName'..."
$roleAssignment = az role assignment create --assignee $identityPrincipalId --role $roleName --scope "/subscriptions/$SubscriptionId/resourceGroups/$resourceGroupName" --output json | ConvertFrom-Json

Write-Host "Role '$roleName' assigned to managed identity '$identityName' with scope '$resourceGroupName'. Assignment Id: $($roleAssignment.id)"

# Enable Chaos Studio on your VMSS a target and capability
$clientId = $identity.clientId
az deployment sub create --template-file "..\..\infra\bicep\vmss_chaos\main.bicep" --location $Location --parameters subscriptionId=$SubscriptionId resourceGroupName=$nodeResourceGroup vmssName=$foundVmssNames clientId=$clientId tenantId=$Tenant

# Check & Enable automatic OS upgrades for the found VMSS
# This is necessary for Chaos Agent Installation
foreach ($vmssName in $foundVmssNames) {
    Write-Host "Checking automatic OS upgrade status for VMSS '$vmssName'..."
    $vmss = az vmss show --name $vmssName --resource-group $nodeResourceGroup --output json | ConvertFrom-Json
    if (-Not $vmss.upgradePolicy.automaticOSUpgrade) {
        Write-Host "Enabling automatic OS upgrade for VMSS '$vmssName'..."
        az vmss update --name $vmssName --resource-group $nodeResourceGroup --set upgradePolicy.automaticOSUpgrade=true --output none
        Write-Host "Automatic OS upgrade has been enabled for VMSS '$vmssName'."
    } else {
        Write-Host "Automatic OS upgrade is already enabled for VMSS '$vmssName'."
    }
}
