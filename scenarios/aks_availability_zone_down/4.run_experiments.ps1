. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\run_experiment.ps1

# Call the function to start the experiment
$AsyncOperationUrl = StartChaosExperiment -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ExperimentName $ExperimentName -ApiVersion $ApiVersion
$AsyncOperationUrl 

# Optionally monitor the async operation
if ($AsyncOperationUrl) {
    Write-Host "Monitoring Async Operation for Experiment: $ExperimentName"
    # Logic to monitor the async operation...
}
