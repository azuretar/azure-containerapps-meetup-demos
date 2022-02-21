
RESOURCE_GROUP="my-containerapps"
LOCATION="canadacentral"
CONTAINERAPPS_ENVIRONMENT="containerapps-env"
LOG_ANALYTICS_WORKSPACE="containerapps-logs"
STORAGE_ACCOUNT_CONTAINER="mycontainer"
STORAGE_ACCOUNT ?= "viperdanstorage113"


help:		## Show this help
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

first-setup: ## Only required on first-setup
	az extension show -n containerapp -o none || \
	az extension add --upgrade \
  	--source https://workerappscliextension.blob.core.windows.net/azure-cli-extension/containerapp-0.2.2-py2.py3-none-any.whl

create-rg:		## 01-Create resouce group
	az group create \
	--name $(RESOURCE_GROUP) \
	--location $(LOCATION)

create-laworkspace:   ## 02-Create LA Workspace
	az monitor log-analytics workspace create \
    --resource-group $(RESOURCE_GROUP) \
    --workspace-name $(LOG_ANALYTICS_WORKSPACE)
	

create-containerappenv:	LOG_ANALYTICS_WORKSPACE_CLIENT_ID = $(shell az monitor log-analytics \
										workspace show \
										--query customerId \
										-g $(RESOURCE_GROUP) \
										-n $(LOG_ANALYTICS_WORKSPACE) --out tsv)
						LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET = $(shell az monitor log-analytics \
										    workspace get-shared-keys \
										    --query primarySharedKey \
										    -g $(RESOURCE_GROUP) \
										    -n $(LOG_ANALYTICS_WORKSPACE) --out tsv)

create-containerappenv: create-containerappenvironment ## 03-Create Container App Environment

create-containerappenvironment: 
	az containerapp env create \
  	--name $(CONTAINERAPPS_ENVIRONMENT) \
  	--resource-group $(RESOURCE_GROUP) \
  	--logs-workspace-id "${LOG_ANALYTICS_WORKSPACE_CLIENT_ID}" \
 	--logs-workspace-key "${LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET}" \
  	--location $(LOCATION)


create-storageaccount:  ## 04-Create Storage Account
	az storage account create \
	--name $(STORAGE_ACCOUNT) \
	--resource-group $(RESOURCE_GROUP) \
	--location $(LOCATION) \
	--sku Standard_RAGRS \
	--kind StorageV2

config-daprcomponent: STORAGE_ACCOUNT_KEY ?= $(shell az storage account keys list \
					 --resource-group $(RESOURCE_GROUP) \
					 --account-name $(STORAGE_ACCOUNT) \
					 --query '[0].value' --out tsv)

config-daprcomponent: set-envvars  ## 05-Configure DAPR component

export STORAGE_ACCOUNT_YAML=$(STORAGE_ACCOUNT) 
export STORAGE_ACCOUNT_CONTAINER_YAML=$(STORAGE_ACCOUNT_CONTAINER) 
export STORAGE_ACCOUNT_KEY_YAML="${STORAGE_ACCOUNT_KEY}"
set-envvars: 
	envsubst < components.template.yaml > components.yaml

deploy-serviceapp: ## 05-Deploy service app
	az containerapp create \
	--name nodeapp \
	--resource-group $(RESOURCE_GROUP) \
	--environment $(CONTAINERAPPS_ENVIRONMENT) \
	--image dapriosamples/hello-k8s-node:latest \
	--target-port 3000 \
	--ingress 'external' \
	--min-replicas 1 \
	--max-replicas 1 \
	--enable-dapr \
	--dapr-app-port 3000 \
	--dapr-app-id nodeapp \
	--dapr-components ./components.yaml

deploy-clientapp: ## 06-Deploy client app
	az containerapp create \
	--name pythonapp \
	--resource-group $(RESOURCE_GROUP) \
	--environment $(CONTAINERAPPS_ENVIRONMENT) \
	--image dapriosamples/hello-k8s-python:latest \
	--min-replicas 1 \
	--max-replicas 1 \
	--enable-dapr \
	--dapr-app-id pythonapp

clean: ## 07-Clean up everything
	az group delete \
	--name $(RESOURCE_GROUP)
