targetScope = 'subscription'

param location string = 'swedencentral'
param subscriptionId string = ''
param resourceGroupName string = 'aksbicep1-rg_aks_akstest01_nodes'
param vmssName string = 'aks-systempool-16370484-vmss'
param clientId string
param tenantId string

module vmssChaosModule './chaosTarget.bicep' = {
  name: 'chaosTargetDeployment-${uniqueString(resourceGroupName, vmssName)}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    vmssName: vmssName
    clientId: clientId
    tenantId:tenantId
  }
}
