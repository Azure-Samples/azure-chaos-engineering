# Set the subscription ID and Azure resource group variables
. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\create_experiment.ps1
. ..\..\scripts\chaos_studio\assign_identity_experiment.ps1
. ..\..\scripts\vmss\get_vmss_instances.ps1

#Connect-AzAccount -Tenant $Tenant
Set-AzContext -Subscription $SubscriptionId
$ExperimentFiles = Get-ChildItem -Path "..\..\experiments\vmss\" -Filter "*.json"
$ApiVersion = "2023-11-01"


# Retrieve the AKS cluster details to find the node resource group
Write-Host "Retrieving AKS cluster details for '$clusterName'..."
$aksClusterDetails = az aks show --name $clusterName --resource-group $resourceGroupName --output json | ConvertFrom-Json
$nodeResourceGroup = $aksClusterDetails.nodeResourceGroup

# List all VMSS in the node resource group and find the VMSS for the agent pool
Write-Host "Retrieving VMSS list from node resource group '$nodeResourceGroup'..."
$vmssList = az vmss list --resource-group $nodeResourceGroup --output json | ConvertFrom-Json

# Extract and display the VMSS names
$foundVmssNames = $vmssList | ForEach-Object { $_.name }
if ($foundVmssNames.Length -gt 0) {
    Write-Host "VMSS names found in node resource group '$nodeResourceGroup':"
    $foundVmssNames | ForEach-Object { Write-Host $_ }
}
else {
    Write-Host "No VMSS found in node resource group '$nodeResourceGroup'."
}

$TargetType = "service"
$File.BaseName 

$ScaleSetInstance = Get-VMSSInstanceIndexesString -VmssName $foundVmssNames -ResourceGroupName $nodeResourceGroup

foreach ($File in $ExperimentFiles) {
    
     if($File.BaseName -like "agent_*") {
        $TargetType = "agent"
    } else {
        $TargetType = "unknown"
    }


    $TargetType
    $Response = CreateChaosStudioExperiment -ExperimentFilePath $File.FullName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ApiVersion $ApiVersion -Location $Location  -VmssResourceGroupName $nodeResourceGroup -VmssName $foundVmssNames -VmssExperimentType $TargetType -ScaleSetInstance $ScaleSetInstance -TargetType "VMSS" 
    $Response
    $ExperimentName = $File.BaseName
    $ExperimentName    
 
}   

#Write-Host "Waiting for 1 minutes for the experiment to be created and to assign RBAC roles to managed identities..."
Start-Sleep 60

foreach ($File in $ExperimentFiles) {
    
    $ExperimentName = $File.BaseName
   
    $RoleName = "Contributor"
    $ResourceTypePrefix = "Microsoft.Compute/virtualMachineScaleSets"
    

    AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId `
        -ResourceGroupName $nodeResourceGroup `
        -ExperimentResourceGroupName $ResourceGroupName `
        -ExperimentName $ExperimentName `
        -ResourceTypePrefix $ResourceTypePrefix `
        -ResourceName $foundVmssNames  `
        -RoleName $RoleName `
        -ApiVersion $ApiVersion
    
}