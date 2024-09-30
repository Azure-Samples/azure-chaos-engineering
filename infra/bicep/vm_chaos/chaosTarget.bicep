param location string
param vmName string
param clientId string
param tenantId string

resource vmResource 'Microsoft.Compute/virtualMachines@2021-04-01' existing = {
  name: vmName
}


resource chaosServiceTarget 'Microsoft.Chaos/targets@2024-01-01' = {
  name: 'microsoft-virtualmachine'
  location: location
  properties: {}
  scope: vmResource
}

resource chaosCapabilityRedeploy 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosServiceTarget
  name: 'Redeploy-1.0'
  location: location
  properties: {}
}

resource chaosCapabilityShutdown 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosServiceTarget
  name: 'Shutdown-1.0'
  location: location
  properties: {}
}

resource chaosTarget 'Microsoft.Chaos/targets@2024-01-01' = {
  name: 'Microsoft-Agent'
  location: location
  properties: {
    identities: [
      {
        type: 'AzureManagedIdentity'
        clientId: clientId
        tenantId: tenantId // Include the tenant ID here
      }
    ]
  }
  scope: vmResource
}

// Define all capabilities for VM
var capabilitiesVM = [
  'StressNg-1.0'
  'CPUPressure-1.0'
  'DiskIOPressure-1.1'
  'DnsFailure-1.0'
  'KillProcess-1.0'
  'LinuxDiskIOPressure-1.1'
  'NetworkDisconnect-1.1'
  'NetworkDisconnectViaFirewall-1.0'
  'NetworkIsolation-1.0'
  'NetworkLatency-1.1'
  'NetworkPacketLoss-1.0'
  'PauseProcess-1.0'
  'PhysicalMemoryPressure-1.0'
  'StopService-1.0'
  'TimeChange-1.0'
  'VirtualMemoryPressure-1.0'
]

// Create all capabilities as child resources
resource chaosCapabilities 'Microsoft.Chaos/targets/capabilities@2024-01-01' = [for capability in capabilitiesVM: {
  parent: chaosTarget
  name: capability
  location: location
  properties: {}
}]


param chaosAgentExtensionName string = 'ChaosAgent'
param chaosAgentPublisher string = 'Microsoft.Azure.Chaos'
param chaosAgentType string = 'ChaosLinuxAgent'
param chaosAgentTypeHandlerVersion string = '1.0'



// VMSS extension resource to install Chaos Agent
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmResource
  name: chaosAgentExtensionName
  location: location
  properties: {
    publisher: chaosAgentPublisher
    type: chaosAgentType
    typeHandlerVersion: chaosAgentTypeHandlerVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: false
    settings: {
      'auth.msi.clientid': clientId
      profile: chaosTarget.properties.agentProfileId // Reference agentProfileId from the Chaos target
      // Other necessary settings...
    }
    protectedSettings: {
      // Sensitive settings here...
    }
  }
}
