. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\run_experiment.ps1

# Specify the experiment file directly
$ExperimentFile = "..\..\experiments\vms\agent_vm_cpu_pressure.json"

# Extract the experiment name from the filename (without extension)
$ExperimentName = [System.IO.Path]::GetFileNameWithoutExtension($ExperimentFile).Trim()
$ExperimentName

# Call the function to start the experiment
$AsyncOperationUrl = StartChaosExperiment -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ExperimentName $ExperimentName -ApiVersion $ApiVersion
$AsyncOperationUrl 

# Optionally monitor the async operation
if ($AsyncOperationUrl) {
    Write-Host "Monitoring Async Operation for Experiment: $ExperimentName"
    # Logic to monitor the async operation...
}
