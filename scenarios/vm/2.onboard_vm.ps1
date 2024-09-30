. .\0.parameters.ps1

az account set --subscription $SubscriptionId

# Create a managed identity for the VM
$identityName = $vmName + "-mi"
Write-Host "Creating Managed Identity '$identityName' in resource group '$resourceGroupName'..."
$identity = az identity create --name $identityName --resource-group $resourceGroupName --location $Location | ConvertFrom-Json

$identityPrincipalId = $identity.principalId

# Check if the $identityPrincipalId is not null or empty
if ([string]::IsNullOrWhiteSpace($identityPrincipalId)) {
    Write-Host "Error retrieving the principal ID for the managed identity '$identityName'."
    exit
}

$roleAs

Write-Host "Assigning role 'Contributor' to the managed identity..."
$roleName ="Contributor"

$roleAssignment = az role assignment create --assignee $identityPrincipalId --role $roleName --scope "/subscriptions/$SubscriptionId/resourceGroups/$resourceGroupName" --output json | ConvertFrom-Json
Write-Host "Role '$roleName' assigned to managed identity '$identityName' with scope '$resourceGroupName'. Assignment Id: $($roleAssignment.id)"

# Deploy the Chaos Studio target and capabilities to the VM
Write-Host "Deploying Chaos Studio to VM '$vmName'..."

# Provide the path to the main.bicep file which will deploy the Chaos Agent and associated capabilities
$mainBicepPath = "..\..\infra\bicep\vm_chaos\main.bicep" 
az deployment sub create --location $Location --template-file $mainBicepPath --parameters subscriptionId=$SubscriptionId resourceGroupName=$resourceGroupName vmName=$vmName clientId=$identityPrincipalId tenantId=$Tenant location=$Location

Write-Host "Chaos Studio deployment has been initiated for VM '$vmName'."
