function Onboard-ChaosResource {
    param (
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$ResourceLocation,
        [string]$ResourceType, # "vm" or "vmss"
        [string]$ResourceName,
        [string]$IdentityName = "",
        [string]$TenantId
    )

    # Login and set context
    Set-AzureContext -SubscriptionId $SubscriptionId

    # Common deployment parameters
    $CommonDeploymentParameters = @{
        subscriptionId = $SubscriptionId
        resourceGroupName = $ResourceGroupName
        vmssName = if ($ResourceType -eq "vmss") { $ResourceName } else { "" }
        vmName = if ($ResourceType -eq "vm") { $ResourceName } else { "" }
        location = $ResourceLocation
        clientId = $IdentityPrincipalId # Managed Identity clientId for VMSS or VM
        tenantId = $TenantId
    }

    # Choose the Bicep template based on ResourceType and construct deployment parameters
    $BicepTemplatePath, $DeploymentParameters = switch ($ResourceType) {
        "vm" {
            "../infra/bicep/vm_chaos/main.bicep", $CommonDeploymentParameters
        }
        "vmss" {
            "../infra/bicep/vmss_chaos/main.bicep", $CommonDeploymentParameters + @{
                virtualMachineScaleSetInstances = $ScaleSetInstance
            }
        }
        default {
            throw "Invalid ResourceType parameter. Must be 'vm' or 'vmss'."
        }
    }

    # Deploy the Chaos Studio Extension to the resource
    Deploy-BicepTemplate -TemplateFile $BicepTemplatePath `
                         -ResourceGroupName $ResourceGroupName `
                         -TemplateParameters $DeploymentParameters
}
