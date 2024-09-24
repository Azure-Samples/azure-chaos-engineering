$ApiVersion = "2024-01-01" # Replace with the actual API version supported

# Function to start a Chaos Experiment
function StartChaosExperiment {
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$ExperimentName,
        [string]$ApiVersion
    )
    
    # Construct the URI for starting the experiment
    $UriStart = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Chaos/experiments/$ExperimentName/start?api-version=$ApiVersion"

    try {
        # Start the experiment
        $StartResponse = Invoke-AzRestMethod -Method Post -Uri $UriStart -Verbose

        if ($StartResponse.StatusCode -eq 202) {
            Write-Host "Experiment started successfully: $ExperimentName"
            return $StartResponse.Headers["Azure-AsyncOperation"]
        } else {
            Write-Host "Failed to start experiment: $ExperimentName. Status code: $($StartResponse.StatusCode)"
        }
    } catch {
        Write-Error "Exception occurred while starting experiment: $ExperimentName. Error: $_"
    }
}
