param redisName string = 'redisDeployment'
param redisLocation string = 'eastus'

module redis 'br/public:avm/res/cache/redis:0.7.1' = {
  name: 'redisDeployment'
  params: {
    // Required parameters
    name:redisName
    // Non-required parameters
    location: redisLocation
  }
}
