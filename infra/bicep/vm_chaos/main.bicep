// main.bicep
targetScope = 'subscription'

param location string = 'eastus'
param subscriptionId string = 'subscription_guid_here'
param resourceGroupName string = 'your_resource_group'
param vmName string = 'your_vm_name'
param clientId string // Client ID of the managed identity with permissions to perform chaos actions
param tenantId string // Tenant ID of your Azure subscription

module vmChaos './chaosTarget.bicep' = {
  name: 'chaosTargetDeployment-${uniqueString(resourceGroupName, vmName)}'
  scope: resourceGroup(subscriptionId, resourceGroupName)

  params: {
    location: location
    vmName: vmName
    clientId: clientId
    tenantId: tenantId
  }
}
