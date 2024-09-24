
param managedClusterName string = 'akscluster'
param location string = 'eastus'
param resourceGroupName string = 'rg-aks-cluster'


module managedCluster 'br/public:avm/res/container-service/managed-cluster:0.3.0' = {
  name: 'managedClusterDeployment'
  params: {
    // Required parameters
    name: managedClusterName
    
    primaryAgentPoolProfile: [
      {
        availabilityZones: [
          '3'
        ]
        count: 3
        mode: 'System'
        name: 'systempool'
        vmSize: 'Standard_DS2_v2'
      }
       
    ]
   
    // Non-required parameters
    aksServicePrincipalProfile: 
    location: location
    publicNetworkAccess:   'Enabled'
    managedIdentities: {
      systemAssigned: true
    }
  }
}
