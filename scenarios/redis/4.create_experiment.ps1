. .\0.parameters.ps1
. ..\..\scripts\chaos_studio\create_experiment.ps1
. ..\..\scripts\chaos_studio\assign_identity_experiment.ps1

#Connect-AzAccount -Tenant $Tenant
Set-AzContext -Subscription $SubscriptionId
$ExperimentFiles = Get-ChildItem -Path "..\..\experiments\redis" -Filter "*.json"
$ApiVersion = "2023-11-01"

# Set the REDIS scope for role assignment
$RedisScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Cache/Redis/$redisName"

# The role 'Contributor' should be sufficient for handling most of the Redis-related operations

$RoleAssignmentCommandFormat = "az role assignment create --assignee `{0}` --role Contributor --scope {1}"

# Replace the placeholder with the actual user or service principal ID and scope (specifically for Redis in this example)
$RoleAssignmentCommand = $RoleAssignmentCommandFormat -f $userOrServicePrincipal, $RedisScope

# Execute the role assignment command
Invoke-Expression $RoleAssignmentCommand


foreach ($File in $ExperimentFiles) {
    $Response = CreateChaosStudioExperiment -ExperimentFilePath $File.FullName -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ApiVersion $ApiVersion -Location $Location  -ClusterName $ClusterName
    $Response
    
    AssignRoleToExperimentIdentity -SubscriptionId $SubscriptionId `
    -ResourceGroupName $ResourceGroupName `
    -ExperimentName $File.BaseName `
    -ResourceTypePrefix "Microsoft.Cache/Redis" `
    -ResourceName $redisName `
    -RoleName "Contributor" `
    -ApiVersion $ApiVersion
    
}
