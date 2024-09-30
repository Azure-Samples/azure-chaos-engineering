function CreateChaosStudioExperiment {
    param (
        [string]$ExperimentFilePath,
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$ApiVersion,
        [string]$Location,
        [string]$ClusterName = "",
        [string]$redisName = "",
        [string]$vmssName = "",
        [string]$VmssResourceGroupName = "",
        [string]$VmssExperimentType = "service",
        [string]$ScaleSetInstance = $null,
        [string]$ExperimentName = "",
        [string]$TargetType = "",
        [string]$vmResourceGroupName="",
        [string]$vmName=""
        
    )
    
    # Load the experiment JSON content from file
    $ExperimentJsonContent = Get-Content -Path $ExperimentFilePath -Raw
    
    # Replace the placeholders with actual values
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<location>", $Location
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<subscription-id>", $SubscriptionId
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<resource-group-name>", $ResourceGroupName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<cluster-name>", $ClusterName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<redisName>", $redisName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<vmssName>", $vmssName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<vmssResourceGroupName>", $VmssResourceGroupName
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<selectorId>", [guid]::NewGuid().ToString()
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<scaleSetInstance>", $ScaleSetInstance
    $ExperimentJsonContent = $ExperimentJsonContent -replace "<vmName>", $vmName
   
    Write-Host "VmssResourceGroupName: '$VmssResourceGroupName'"
    Write-Host "vmssName: '$vmssName'"
    Write-Host "VmssExperimentType: '$VmssExperimentType'"

    if (![string]::IsNullOrWhiteSpace($vmResourceGroupName) -and ![string]::IsNullOrWhiteSpace($vmName)) {
        $vmTargetId = "/subscriptions/$SubscriptionId/resourceGroups/$vmResourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/providers/Microsoft.Chaos/targets/microsoft-virtualmachine"
        $ExperimentJsonContent = $ExperimentJsonContent -replace "<vm-target-id>", $vmTargetId
        Write-Host "vmTargetId: '$vmTargetId'"
    }
    elseif (![string]::IsNullOrWhiteSpace($VmssResourceGroupName) -and ![string]::IsNullOrWhiteSpace($vmssName)) {
        if ($VmssExperimentType -eq "agent") {
            $VmssTargetId = "/subscriptions/$SubscriptionId/resourceGroups/$VmssResourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$vmssName/providers/Microsoft.Chaos/targets/Microsoft-Agent"
            $ExperimentJsonContent = $ExperimentJsonContent -replace "<vmss-target-id>", $VmssTargetId
        }
        elseif ($VmssExperimentType -eq "service") {
            $VmssTargetId = "/subscriptions/$SubscriptionId/resourceGroups/$VmssResourceGroupName/providers/Microsoft.Compute/virtualMachineScaleSets/$vmssName/providers/Microsoft.Chaos/targets/microsoft-virtualmachinescaleset"
            $ExperimentJsonContent = $ExperimentJsonContent -replace "<vmss-target-id>", $VmssTargetId
        }

        Write-Host "VmssTargetId: '$VmssTargetId'"
    }

  
    if ($TargetType -ne "VMSS") {
        # Remove the VMSS parameters block by using regex to match the tags
        $ExperimentJsonContent = $ExperimentJsonContent -replace "/\*<vmss_params>.*?</vmss_params>\*/", ""
    }
    else {
        # Only replace the placeholder inside the tags for VMSS experiments
        $ExperimentJsonContent = $ExperimentJsonContent -replace "<ScaleSetInstance>", $ScaleSetInstance
    }
    
    $ExperimentJsonContent = $ExperimentJsonContent | ConvertFrom-Json | ConvertTo-Json -Depth 10

    # Extract the experiment name from the filename (without extension)
    if (-not $ExperimentName) {
        $ExperimentName = [System.IO.Path]::GetFileNameWithoutExtension((Get-Item $ExperimentFilePath).Name).Trim()
    }
    # Construct the REST API endpoint URI
    $UriFormat = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Chaos/experiments/{2}?api-version={3}"
    $Uri = $UriFormat -f $SubscriptionId, $ResourceGroupName, $ExperimentName, $ApiVersion

    

    
    try {
        # Create the experiment using the Azure REST API
        $Response = Invoke-AzRestMethod -Method Put -Uri $Uri -Payload $ExperimentJsonContent -Verbose
    
        if ($Response.StatusCode -eq 201 -or $Response.StatusCode -eq 200) {
            Write-Host "Successfully created experiment: $ExperimentName"
        }
        else {
            Write-Host "Not Successfully created experiment: $ExperimentName"
        }
        return $Response
    }
    catch {
        Write-Error "Failed to create experiment: $ExperimentName. Error: $_"
    }
}