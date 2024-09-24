function AssignRoleToExperimentIdentity {
    param (
        [Parameter(Mandatory)]
        [string]$SubscriptionId,

        [Parameter(Mandatory)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory)]
        [string]$ExperimentName,

        [Parameter(Mandatory)]
        [string]$ResourceTypePrefix,

        [Parameter(Mandatory)]
        [string]$ResourceName,

        [Parameter(Mandatory)]
        [string]$RoleName,

        [Parameter(Mandatory)]
        [string]$ApiVersion
    )

    # Construct the REST API endpoint URI for the experiment
    $UriFormat = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Chaos/experiments/{2}?api-version={3}"
    $Uri = $UriFormat -f $SubscriptionId, $ResourceGroupName, $ExperimentName, $ApiVersion

    # Retrieve the Principal ID for the managed identity of the experiment
    $Experiment = Invoke-AzRestMethod -Method Get -Uri $Uri
    $ExperimentPrincipalId = ($Experiment.Content | ConvertFrom-Json).identity.principalId

    # Assign permissions for the managed identity to the specified Resource
    $ResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/$ResourceTypePrefix/$ResourceName"
    $RoleAssignments = Get-AzRoleAssignment -ObjectId $ExperimentPrincipalId -RoleDefinitionName $RoleName -Scope $ResourceId -ErrorAction SilentlyContinue

    if ($null -eq $RoleAssignments) {
        # Role assignment does not exist, so create it
        New-AzRoleAssignment -ObjectId $ExperimentPrincipalId -RoleDefinitionName $RoleName -Scope $ResourceId
        Write-Host "Assigned $RoleName role to Principal ID $ExperimentPrincipalId for Resource: $ResourceId"
    }
    else {
        Write-Host "Role assignment already exists for Principal ID $ExperimentPrincipalId on the Resource: $ResourceId"
    }
}

# Example usage of the function:
# AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ExperimentName "my-experiment" -ResourceTypePrefix "Microsoft.Cache/Redis" -ResourceName $redisName -RoleName "Contributor" -ApiVersion "2023-11-01"
