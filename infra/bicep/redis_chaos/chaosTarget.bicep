param redisName string
param location string = 'swedencentral'

// Assuming the Redis resource exists within the resourceGroup
resource redisResource 'Microsoft.Cache/Redis@2021-03-01' existing = {
  name: redisName
  // Note: 'scope: resourceGroup()' is implicit for 'existing' resources
}

// Create the Chaos target within the Redis resource scope
resource chaosTarget 'Microsoft.Chaos/targets@2024-01-01' = {
  scope: redisResource
  name: 'microsoft-azureclusteredcacheforredis' // Create a unique name with a suffix, if needed
  location: location
  properties: {
    description: 'Chaos Target for Azure Cache for Redis'
  }
}

// Child resource for the reboot capability tied to the Chaos target
resource redisChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'Reboot-1.0'
  properties: {
    description: 'Forces a reboot operation on the Azure Cache for Redis instance to simulate a brief outage.'
    urn: 'urn:csci:microsoft:azureClusteredCacheForRedis:reboot/1.0'
    parameters: {
      rebootType: 'AllNodes'
      shardId: '0' // Only specify for Premium caches that use sharding
    }
  }
}

output chaosTargetId string = chaosTarget.id
output redisChaosCapabilityId string = redisChaos.id
