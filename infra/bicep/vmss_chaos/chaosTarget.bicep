param location string = 'swedencentral'
param vmssName string
param clientId string 
param tenantId string

resource vmssResource 'Microsoft.Compute/virtualMachineScaleSets@2021-04-01' existing = {
  name: vmssName
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
  scope: vmssResource
}

// Define each capability based on the ARM template provided
var capabilities = [
  'StressNg-1.0', 'CPUPressure-1.0', 'DiskIOPressure-1.1', 'DnsFailure-1.0', 'KillProcess-1.0', 'LinuxDiskIOPressure-1.1', 'NetworkDisconnect-1.1', 'NetworkDisconnectViaFirewall-1.0', 'NetworkIsolation-1.0', 'NetworkLatency-1.1', 'NetworkPacketLoss-1.0', 'PauseProcess-1.0', 'PhysicalMemoryPressure-1.0', 'StopService-1.0', 'TimeChange-1.0', 'VirtualMemoryPressure-1.0'
]

// Dynamically create the capability resources
resource capabilitiesResources 'Microsoft.Chaos/targets/capabilities@2024-01-01' = [for capability in capabilities: {
  name: capability
  parent: chaosTarget
  location: location
  properties: {}
  
}]


// Create the Chaos target for the VMSS
resource chaosTargetDirect 'Microsoft.Chaos/targets@2024-01-01' = {
  name: 'microsoft-virtualmachinescaleset'
  location: location
  properties: {}
  scope: vmssResource
}

// Define the first capability (Shutdown-1.0) for the Chaos Target
resource shutdownCapabilityOne 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTargetDirect
  name: 'Shutdown-1.0'
  location: location
  properties: {}
}

// Define the second capability (Shutdown-2.0) for the Chaos Target
resource shutdownCapabilityTwo 'Microsoft.Chaos/targets/capabilities@2024-01-01' = {
  parent: chaosTargetDirect
  name: 'Shutdown-2.0'
  location: location
  properties: {}
}

param chaosAgentExtensionName string = 'ChaosAgent'
param chaosAgentPublisher string = 'Microsoft.Azure.Chaos'
param chaosAgentType string = 'ChaosLinuxAgent'
param chaosAgentTypeHandlerVersion string = '1.0'



// VMSS extension resource to install Chaos Agent
resource vmssExtension 'Microsoft.Compute/virtualMachineScaleSets/extensions@2021-07-01' = {
  parent: vmssResource
  name: chaosAgentExtensionName
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
