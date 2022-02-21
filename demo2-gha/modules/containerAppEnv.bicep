param workspace_name string
param location string
param environment_name string


// Create LA Workspace
resource createLAWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspace_name
  location: location
}

//Create Container App Environment
resource createContainerAppEnv 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: environment_name
  location: location
  kind: 'containerenvironment'
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: createLAWorkspace.properties.customerId
        sharedKey: createLAWorkspace.listKeys().primarySharedKey
      }
    }
  }
}
