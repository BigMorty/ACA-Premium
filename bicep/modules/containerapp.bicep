param location string
param containerAppsEnvName string 
param containerAppName string
param image string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

resource environment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: containerAppsEnvName
}

resource containerApp 'Microsoft.App/containerapps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    workloadProfileType: 'GP1'
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
        transport: 'Auto'
        allowInsecure: true
      }
    }
    template: {
      containers: [
        {
          name: 'main'
          image: image
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
      }
    }
  }
}
