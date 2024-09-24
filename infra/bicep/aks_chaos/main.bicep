targetScope = 'subscription'

param subscriptionId string = 'de80dbb8-a2dc-4ba1-8058-af99f88c8de1'
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

