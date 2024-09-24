function CreateChaosStudioExperiment {
    param (
        [string]$ExperimentFilePath,
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$ApiVersion,
        [string]$Location,
        [string]$ClusterName
    )
    
    # Load the experiment JSON content from file
    $ExperimentJsonContent = Get-Content -Path $ExperimentFilePath -Raw
    
    # Replace the placeholders with actual values
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<location>", $Location
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<subscription-id>", $SubscriptionId
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<resource-group-name>", $ResourceGroupName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<cluster-name>", $ClusterName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<redisName>", $ClusterName
    # Extract the experiment name from the filename (without extension)
    $ExperimentName = [System.IO.Path]::GetFileNameWithoutExtension((Get-Item $ExperimentFilePath).Name).Trim()
    
    # Construct the REST API endpoint URI
    $UriFormat = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Chaos/experiments/{2}?api-version={3}"
    $Uri = $UriFormat -f $SubscriptionId, $ResourceGroupName, $ExperimentName, $ApiVersion
    
    try {
        # Create the experiment using the Azure REST API
        $Response = Invoke-AzRestMethod -Method Put -Uri $Uri -Payload $ExperimentJsonContent -Verbose
        if ($Response.StatusCode -eq 201 -or $Response.StatusCode -eq 200) {
            Write-Host "Successfully created experiment: $ExperimentName"
        }
        return $Response
    }
    catch {
        Write-Error "Failed to create experiment: $ExperimentName. Error: $_"
    }
}