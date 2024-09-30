# Load parameters and functions
. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\create_experiment.ps1
. ..\..\scripts\chaos_studio\assign_identity_experiment.ps1

# Set Azure context to the target subscription
Set-AzContext -Subscription $SubscriptionId
$ApiVersion = "2023-11-01"

# Get all experiment JSON files
$ExperimentFiles = Get-ChildItem -Path (Join-Path -Path "..\..\experiments\vm\" -ChildPath "*.json")
$CreatedExperiments = @()

foreach ($File in $ExperimentFiles) {
    # Determine target type based on experiment file name
    switch -Wildcard ($File.BaseName) {
        "agent_*" { $TargetType = "agent" }
        "*_vmss_*" { continue }
        default { $TargetType = "unknown" }
    }

    # Create a Chaos Studio experiment targeting the single VM
    $Response = CreateChaosStudioExperiment -ExperimentFilePath $File.FullName `
        -SubscriptionId $SubscriptionId `
        -ResourceGroupName $ResourceGroupName `
        -vmResourceGroupName $ResourceGroupName `
        -ApiVersion $ApiVersion `
        -Location $Location `
        -VmName $VmName `
        -ExperimentType $TargetType `
        -TargetType "VM"
    $Response

    # Add experiment name to the list for role assignment
    $CreatedExperiments += $File.BaseName
}

# Brief pause for proper role assignment after experiment creation
Start-Sleep -Seconds 60

foreach ($ExperimentName in $CreatedExperiments) {
    $RoleName = "Contributor"
    $ResourceTypePrefix = "Microsoft.Compute/virtualMachines"

    # Assign role to the managed identity of the experiment for the single VM
    AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId `
        -ResourceGroupName $ResourceGroupName `
        -ExperimentResourceGroupName $ResourceGroupName `
        -ExperimentName $ExperimentName `
        -ResourceTypePrefix $ResourceTypePrefix `
        -ResourceName $VmName `
        -RoleName $RoleName `
        -ApiVersion $ApiVersion
}
