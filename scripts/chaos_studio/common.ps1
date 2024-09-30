function Create-ManagedIdentity {
    param (
        [string]$IdentityName,
        [string]$ResourceGroupName,
        [string]$Location
    )
    
    # Create a managed identity
    Write-Host "Creating Managed Identity '$IdentityName' in resource group '$ResourceGroupName'..."
    return az identity create --name $IdentityName --resource-group $ResourceGroupName --location $Location --output json | ConvertFrom-Json
}

function Assign-Role {
    param (
        [string]$IdentityPrincipalId,
        [string]$RoleName,
        [string]$ResourceGroupName,
        [string]$SubscriptionId
    )
    
    # Assign role to the managed identity
    $Scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
    Write-Host "Assigning role '$RoleName' to managed identity principal ID '$IdentityPrincipalId' with scope '$Scope'..."
    return az role assignment create --assignee $IdentityPrincipalId --role $RoleName --scope $Scope --output json | ConvertFrom-Json
}

function Find-VMSSInNodeResourceGroup {
    param (
        [string]$NodeResourceGroup
    )
    
    # Retrieve VMSS list and return names
    return az vmss list --resource-group $NodeResourceGroup --output json | ConvertFrom-Json | ForEach-Object { $_.name }
}