. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\run_experiment.ps1


# Retrieve all experiments
$ExperimentFiles = Get-ChildItem -Path "..\..\experiments\aks" -Filter "*.json"

foreach ($File in $ExperimentFiles) {
    # Extract the experiment name from the filename (without extension)
    $ExperimentName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name).Trim()

    # Call the function to start each experiment
    $AsyncOperationUrl = StartChaosExperiment -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ExperimentName $ExperimentName -ApiVersion $ApiVersion
    
    # Optionally monitor the async operation
    if ($AsyncOperationUrl) {
        Write-Host "Monitoring Async Operation for Experiment: $ExperimentName"
        # Logic to monitor the async operation...
    }
}


