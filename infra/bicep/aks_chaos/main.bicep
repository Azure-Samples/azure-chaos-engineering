targetScope = 'subscription'

param subscriptionId string = ''
param resourceGroupName string = 'aksbicep1-rg'
param clusterName string = 'AKSTEST'
param location string = 'swedencentral'

module chaosTargetModule 'chaosTarget.bicep' = {
  name: 'chaosTargetDeployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    clusterName: clusterName
    location: location
  }
}

