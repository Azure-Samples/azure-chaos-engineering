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
        [string]$ApiVersion,

        [Parameter(Mandatory=$false)]
        [string]$ExperimentResourceGroupName
    )

    if (-not $ExperimentResourceGroupName) {
        $ExperimentResourceGroupName = $ResourceGroupName
    }

    Write-Host "Assigning role to experiment identity for experiment: $ExperimentName"

    # Construct the REST API endpoint URI for the experiment
    $UriFormat = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Chaos/experiments/{2}?api-version={3}"
    $Uri = $UriFormat -f $SubscriptionId, $ExperimentResourceGroupName, $ExperimentName, $ApiVersion

    try {
        # Retrieve the Principal ID for the managed identity of the experiment
        $ExperimentResponse = Invoke-AzRestMethod -Method Get -Uri $Uri -ErrorAction Stop
        if ($ExperimentResponse.StatusCode -eq 200) {
            $Experiment = $ExperimentResponse.Content | ConvertFrom-Json
            $ExperimentPrincipalId = $Experiment.identity.principalId

            if (-not $ExperimentPrincipalId) {
                Write-Host "Identity Principal ID for experiment '$ExperimentName' is not found."
                return
            }

            # Ensure the experiment has managed identity with role assignable
            if ($Experiment.identity.type -ne "SystemAssigned") {
                Write-Host "The experiment '$ExperimentName' does not have a SystemAssigned managed identity."
                return
            }

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
        else {
            $ExperimentResponse
            Write-Host "Failed to retrieve experiment '$ExperimentName'. Status Code: $($ExperimentResponse.StatusCode)"
        }
    }
    catch {
        Write-Host "An error occurred while assigning role to the experiment identity: $_"
    }
}

# Example usage of the function:
# AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ExperimentName "my-experiment" -ResourceTypePrefix "Microsoft.Compute/virtualMachineScaleSets" -ResourceName $vmssName -RoleName "Contributor" -ApiVersion "2023-11-01"
