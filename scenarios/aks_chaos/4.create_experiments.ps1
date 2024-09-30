# Set the subscription ID and Azure resource group variables
. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\create_experiment.ps1
. ..\..\scripts\chaos_studio\assign_identity_experiment.ps1

#Connect-AzAccount -Tenant $Tenant
Set-AzContext -Subscription $SubscriptionId
$ExperimentFiles = Get-ChildItem -Path "..\..\experiments\aks" -Filter "*.json"
$ApiVersion = "2023-11-01"

# Execute the role assignment command
Invoke-Expression $RoleAssignmentCommand


foreach ($File in $ExperimentFiles) {
    $Response = CreateChaosStudioExperiment -ExperimentFilePath $File.FullName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ApiVersion $ApiVersion -Location $Location  -ClusterName $ClusterName
    $Response
    
    AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId `
        -ResourceGroupName $ResourceGroupName `
        -ExperimentName $File.BaseName `
        -ResourceTypePrefix "Microsoft.ContainerService/managedClusters" `
        -ResourceName $clusterName `
        -RoleName "Azure Kubernetes Service Cluster Admin Role" `
        -ApiVersion $ApiVersion
    
}
