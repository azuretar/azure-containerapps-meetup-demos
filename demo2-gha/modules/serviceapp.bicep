param location string = 'canadacentral'
param environment_name string
param storage_account_name string
param storage_container_name string

resource storageAccountObject 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storage_account_name
}

resource nodeapp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'nodeapp'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }
      secrets: [
        {
          name: 'storage-key'
          value: storageAccountObject.listKeys().keys[0].value
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'dapriosamples/hello-k8s-node:latest'
          name: 'hello-k8s-node'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      dapr: {
        enabled: true
        appPort: 3000
        appId: 'nodeapp'
        components: [
          {
            name: 'statestore'
            type: 'state.azure.blobstorage'
            version: 'v1'
            metadata: [
              {
                name: 'accountName'
                value: storage_account_name
              }
              {
                name: 'accountKey'
                secretRef: 'storage-key'
              }
              {
                name: 'containerName'
                value: storage_container_name
              }
            ]
          }
        ]
      }
    }
  }
}
