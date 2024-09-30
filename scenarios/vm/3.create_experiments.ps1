# Set the subscription ID and Azure resource group variables
. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\create_experiment.ps1
. ..\..\scripts\chaos_studio\assign_identity_experiment.ps1

# Set Azure context to the target subscription
Set-AzContext -Subscription $SubscriptionId
$ApiVersion = "2023-11-01"

# No need to retrieve AKS clusters or VMSS instances for a single VM
# ...

$ExperimentFiles = Get-ChildItem -Path "..\..\experiments\vm\" -Filter "*.json"
foreach ($File in $ExperimentFiles) {

    # Determine target type based on experiment file name
    if($File.BaseName -like "agent_*") {
        $TargetType = "agent"
    } else {
        $TargetType = "unknown"
    }

    # Call to create a Chaos Studio experiment targeting the single VM
    $Response = CreateChaosStudioExperiment -ExperimentFilePath $File.FullName -SubscriptionId $SubscriptionId -ResourceGroupName $resourceGroupName -ApiVersion $ApiVersion -Location $Location -VmName $vmName -ExperimentType $TargetType -TargetType "VM"
    $Response

    # Update experiment name for role assignment
    $ExperimentName = $File.BaseName
}   

# Brief pause may be required for proper role assignment after experiment creation
Start-Sleep 60

foreach ($File in $ExperimentFiles) {
    
    $ExperimentName = $File.BaseName
    $RoleName = "Contributor"
    $ResourceTypePrefix = "Microsoft.Compute/virtualMachines"

    # Assign role to the managed identity of the experiment for the single VM
    AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId `
        -ResourceGroupName $resourceGroupName `
        -ExperimentResourceGroupName $resourceGroupName `
        -ExperimentName $ExperimentName `
        -ResourceTypePrefix $ResourceTypePrefix `
        -ResourceName $vmName `
        -RoleName $RoleName `
        -ApiVersion $ApiVersion
}
