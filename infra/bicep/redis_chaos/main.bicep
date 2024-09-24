targetScope = 'resourceGroup'

param redisName string
param location string = 'swedencentral'
param resourceGroupName string

module chaosTargetModule './chaosTarget.bicep' = {
  name: 'chaosTargetDeployment-${uniqueString(resourceGroup().id)}' // Unique deployment name
  params: {
    redisName: redisName
    location: location
  }
}

output chaosTargetId string = chaosTargetModule.outputs.chaosTargetId
output redisChaosCapabilityId string = chaosTargetModule.outputs.redisChaosCapabilityId
