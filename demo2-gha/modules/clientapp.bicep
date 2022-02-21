// client app
param location string = 'canadacentral'
param environment_name string

resource pythonapp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'pythonapp'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {}
    template: {
      containers: [
        {
          image: 'dapriosamples/hello-k8s-python:latest'
          name: 'hello-k8s-python'
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
        appId: 'pythonapp'
      }
    }
  }
}
