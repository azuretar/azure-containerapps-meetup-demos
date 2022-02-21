param location string = 'canadacentral'
param environment_name string
param storage_account_name string

resource storageAccountObject 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storage_account_name
}

resource queuereader 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'queuereader'
  kind: 'containerapp'
  dependsOn: [
    storageAccountObject
  ]
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'queueconnection'
          value: 'DefaultEndpointsProtocol=https;EndpointSuffix=${environment().suffixes.storage};AccountName=${storageAccountObject.name};AccountKey=${listKeys(storageAccountObject.id, storageAccountObject.apiVersion).keys[0].value}'
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-queuereader'
          name: 'queuereader'
          env: [
            {
              name: 'QueueName'
              value: 'myqueue'
            }
            {
              name: 'QueueConnectionString'
              secretRef: 'queueconnection'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [ 
          {
            name: 'myqueuerule'
            azureQueue: {
              queueName: 'myqueue'
              queueLength: 2
              auth: [
                {
                  secretRef: 'queueconnection'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}
