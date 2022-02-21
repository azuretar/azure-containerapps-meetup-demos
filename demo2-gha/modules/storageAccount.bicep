param storageLocation string
param storageName string

var storageUniqueName = '${storageName}${uniqueString(resourceGroup().id)}'
resource createStorageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageUniqueName
  location: storageLocation
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
}

output storageAccountName string = createStorageAccount.name
