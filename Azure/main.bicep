param location string = resourceGroup().location
param dns string

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
  {
    name: 'MainDomain'
    value: 'www.${dns}'
  }
  {
    name: 'SubDomain1'
    value: 'subsite1.${dns}'
  }
  {
    name: 'SubDomain2'
    value: 'subsite2.${dns}'
  }
]

// create the products api container app
module yarpmainsite 'container_app.bicep' = {
  name: 'yarpmainsite'
  params: {
    name: 'yarpmainsite'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: false
  }
}

// create the inventory api container app
module yarpsubsite01 'container_app.bicep' = {
  name: 'yarpsubsite01'
  params: {
    name: 'yarpsubsite01'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: false
  }
}

// create the inventory api container app
module yarpsubsite02 'container_app.bicep' = {
  name: 'yarpsubsite02'
  params: {
    name: 'yarpsubsite02'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: shared_config
    externalIngress: false
  }
}

// create the store api container app
var proxy_config = [
  {
    name: 'MainSite'
    value: 'http://${yarpmainsite.outputs.fqdn}'
  }
  {
    name: 'SubSite01'
    value: 'http://${yarpsubsite01.outputs.fqdn}'
  }
  {
    name: 'SubSite02'
    value: 'http://${yarpsubsite02.outputs.fqdn}'
  }
]

// create the inventory api container app
module yarpproxy 'container_app.bicep' = {
  name: 'yarpproxy'
  params: {
    name: 'yarpproxy'
    location: location
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    containerAppEnvironmentId: env.outputs.id
    registry: acr.name
    envVars: union(shared_config, proxy_config)
    externalIngress: true
  }
}

