param location string = resourceGroup().location
param containerAppName string = 'testapp'
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'da-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'env-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'log-${uniqueSuffix}'
param vnetName string = 'vnet-${uniqueSuffix}'
param vnetPrefix string = '10.0.0.0/16'

var containerAppsSubnet = {
  name: 'ContainerAppsSubnet'
  properties: {
    addressPrefix: '10.0.0.0/23'
  }
}

// Deploy an Azure Virtual Network 
module vnetModule 'modules/vnet.bicep' = {
  name: '${deployment().name}--vnet'
  params: {
    location: location
    vnetName: vnetName
    vnetPrefix: vnetPrefix
  }
}

// Deploy and configure Azure Container Apps 
module containerAppsEnvModule 'modules/ca-environment.bicep' = {
  name: '${deployment().name}--containerAppsEnv'
  dependsOn: [
    vnetModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    containerAppsSubnetProps: containerAppsSubnet
    vnetName: vnetName
  }
}

// Deploy a sample app 
module containerAppModule 'modules/containerapp.bicep' = {
  name: '${deployment().name}--album-api'
  dependsOn: [
    containerAppsEnvModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    containerAppName: containerAppName
  }
}
