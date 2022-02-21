// Main bicep

@description('Location for all resources.')
param location string = 'canadacentral'

@description('Environment name')
param environment_name string

@description('Storage Account name prefix')
param storage_account_name string

@description('Storage account container')
param storage_container_name string

@description('Resource group name')
param resource_group string

@description('LA Workspace name')
param workspace_name string

targetScope = 'subscription'

// Create Resource group
resource createResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: resource_group
  location: location
}


// Create Environment
module createContainerEnv 'modules/containerAppEnv.bicep' = {
  name: 'createContainerEnv'
  scope: createResourceGroup
  params:{
    location: location
    workspace_name: workspace_name
    environment_name: environment_name
  }
}

// Create storage account
module createStorageAcct './modules/storageAccount.bicep' = {
  name: 'createStorageAcct'
  scope: createResourceGroup
  params: {
    storageLocation: location
    storageName: storage_account_name
  }
  dependsOn: [
    createContainerEnv
  ]
}

// Service App Creation
module createServiceApp './modules/serviceapp.bicep' = {
  name: 'createServiceApp'
  scope: createResourceGroup
  params:{
    storage_account_name: createStorageAcct.outputs.storageAccountName
    environment_name: environment_name
    storage_container_name: storage_container_name
    location: location
  }
  dependsOn: [
    createStorageAcct
    createContainerEnv
  ]
}

//Create Client App
module createClientApp './modules/clientapp.bicep' = {
  name: 'createClientApp'
  scope: createResourceGroup
  params: {
    environment_name: environment_name
    location: location
  }
  dependsOn: [
    createServiceApp
  ]
}
