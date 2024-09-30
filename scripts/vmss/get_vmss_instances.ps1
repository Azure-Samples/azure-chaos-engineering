function Get-VMSSInstanceIndexesString {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VmssName,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName
    )
    begin {
        Write-Host "Retrieving instances for VMSS '$VmssName' in resource group '$ResourceGroupName'..."
    }
    process {
        try {
            # List all the instances of the provided VMSS
            $vmssInstances = az vmss list-instances --name $VmssName --resource-group $ResourceGroupName --output json | ConvertFrom-Json

            # Extract the instance IDs and sort them to ensure correct order
            $instanceIndexes = $vmssInstances | Sort-Object { [int] $_.instanceId } | ForEach-Object { $_.instanceId }

            # Create the index string to pass to the experiment parameter
            $indexString = "[{0}]" -f ($instanceIndexes -join ',')
            Write-Host "VMSS '$VmssName' instance indexes: $indexString"
            return $indexString
        }
        catch {
            Write-Error "Error retrieving instances for VMSS '$VmssName': $_"
            return $null
        }
    }
    end {
    }
}

function Get-VMSSInstanceIndexesInAvailabilityZone {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VmssName,

        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [int]$AvailabilityZone
    )
    begin {
        Write-Verbose "Retrieving instances for VMSS '$VmssName' in resource group '$ResourceGroupName' in availability zone '$AvailabilityZone'..."
    }
    process {
        try {
            # List all the instances of the provided VMSS using Azure CLI and convert the JSON output to PowerShell objects
            $vmssInstances = az vmss list-instances --name $VmssName --resource-group $ResourceGroupName --output json | ConvertFrom-Json

            # Filter the instances by the availability zone property
            $filteredInstances = $vmssInstances | Where-Object { $_.zones -contains "$AvailabilityZone" } 

            # Extract the instance IDs and sort them to ensure correct order
            $instanceIndexes = $filteredInstances | Sort-Object { [int] $_.instanceId } | ForEach-Object { $_.instanceId }

            # Create the index string to pass to the experiment parameter
            $indexString = "[{0}]" -f ($instanceIndexes -join ',')
            #Write-Output "VMSS '$VmssName' instance indexes in availability zone '$AvailabilityZone': $indexString"
            return $indexString
        }
        catch {
            Write-Error "Error retrieving instances for VMSS '$VmssName' in availability zone '$AvailabilityZone': $_"
            return $null
        }
    }
    end {
    }
}

