# list all commands triggers tests azurenights

az group create \
  --name $RESOURCE_GROUP \
  --location "$LOCATION"

az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE

LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE -o tsv | tr -d '[:space:]'`

LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE -o tsv | tr -d '[:space:]'`

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET \
  --location "$LOCATION"

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION" \
  --sku Standard_RAGRS \
  --kind StorageV2

STORAGE_ACCOUNT_KEY=`az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' --out tsv`

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file ../main.bicep \
  --parameters \
      environment_name="$CONTAINERAPPS_ENVIRONMENT" \
      location="$LOCATION" \
      storage_account_name="$STORAGE_ACCOUNT" \
      storage_account_key="$STORAGE_ACCOUNT_KEY" \
      storage_container_name="$STORAGE_ACCOUNT_CONTAINER"

# Bicep test
RESOURCE_GROUP="my-container-apps"
LOCATION="canadacentral"
LOG_ANALYTICS_WORKSPACE="my-container-apps-logs"
CONTAINERAPPS_ENVIRONMENT="my-environment"
STORAGE_ACCOUNT="viperdan"

az deployment sub create \
  --name aznightsdemo \
  --location $LOCATION \
  --template-file main.bicep \
  --parameters \
      environment_name="$CONTAINERAPPS_ENVIRONMENT" \
      storage_account_name="$STORAGE_ACCOUNT" \
      storage_container_name="$STORAGE_ACCOUNT_CONTAINER" \
      resource_group="$RESOURCE_GROUP" \
      workspace_name=$LOG_ANALYTICS_WORKSPACE

# GitHub actions creds custpoc.

az ad sp create-for-rbac --name "aznights" --role contributor \
    --scopes /subscriptions/cf44b364-5ffa-4603-9e2a-649c12d1d27f \
    --sdk-auth

# Deploy container apps
    - name: deploy
      uses: azure/arm-deploy@v1
      with:
        scope: subscription
        region: canadacentral
        subscriptionId: ${{ secrets.AZURE_SUBSCRIPTION }}
        deploymentName: aznightsdemo
        template: demo2-gha/main.bicep
        parameters: 
          environment_name=${{ env.CONTAINERAPPS_ENVIRONMENT }}
          storage_account_name=${{ env.STORAGE_ACCOUNT_NAME }}
          storage_container_name=${{ env.STORAGE_ACCOUNT_CONTAINER }}
          resource_group=${{ env.RESOURCE_GROUP }}
          workspace_name=${{ env.LOG_ANALYTICS_WORKSPACE }}
          location=${{ env.LOCATION }}
        failOnStdErr: false