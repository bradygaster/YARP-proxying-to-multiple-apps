param location string = resourceGroup().location

// create the azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: toLower('${resourceGroup().name}acr')
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// create the aca environment
module env 'environment.bicep' = {
  name: 'containerAppEnvironment'
  params: {
    location: location
  }
}

// create the various config pairs
var shared_config = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: env.outputs.appInsightsInstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: env.outputs.appInsightsConnectionString
  }
]

// create the products api container app
module mainsite 'container_app.bicep' = {
  name: 'mainsite'
  params: {
    name: 'mainsite'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: true
  }
}

// create the inventory api container app
module subsite01 'container_app.bicep' = {
  name: 'subsite01'
  params: {
    name: 'subsite01'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: true
  }
}

// create the inventory api container app
module subsite02 'container_app.bicep' = {
  name: 'subsite02'
  params: {
    name: 'subsite02'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: true
  }
}

// create the store api container app
var proxy_config = [
  {
    name: 'MainSite'
    value: 'http://${mainsite.outputs.fqdn}'
  }
  {
    name: 'SubSite01'
    value: 'http://${subsite01.outputs.fqdn}'
  }
  {
    name: 'SubSite02'
    value: 'http://${subsite02.outputs.fqdn}'
  }
]

// create the inventory api container app
module proxy 'container_app.bicep' = {
  name: 'proxy'
  params: {
    name: 'proxy'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: union(shared_config, proxy_config)
    externalIngress: true
  }
}

