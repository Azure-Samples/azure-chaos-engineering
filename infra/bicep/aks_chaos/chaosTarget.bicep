param clusterName string

param location string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' existing = {
  name: clusterName
}

resource chaosTarget 'Microsoft.Chaos/targets@2024-01-01' = {
  scope: aksCluster

  name: 'Microsoft-AzureKubernetesServiceChaosMesh'

  location: location

  properties: {}
}

// Then declare each capability as a sub-resource of chaosTarget
resource dnsChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'DNSChaos-2.1'
  properties: {}
}

// Repeat for other capabilities
resource httpChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'HTTPChaos-2.1'
  properties: {}
}

resource ioChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'IOChaos-2.1'
  properties: {}
}

resource kernelChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'KernelChaos-2.1'
  properties: {}
}

resource networkChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'NetworkChaos-2.1'
  properties: {}
}

resource podChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'PodChaos-2.1'
  properties: {}
}

resource stressChaos 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTarget
  name: 'StressChaos-2.1'
  properties: {}
}
