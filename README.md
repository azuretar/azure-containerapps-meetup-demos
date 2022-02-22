- [Azure Container Apps Demo](#Azure-Container-Apps-Demo)
- [Overview - Demo 1 + 2](#overview---demo-1---2)
  * [Verify the result](#verify-the-result)
    + [Confirm successful state persistence](#confirm-successful-state-persistence)
    + [View Logs](#view-logs)
      - [Bash](#bash)
- [Overview - Demo 3](#overview---demo-3)
  * [Add messages to the Queue](#add-messages-to-the-queue)
  * [Verify the result](#verify-the-result-1)
      - [Bash](#bash-1)

# Azure Container Apps Demo

[![demo2-aznights-feb-2022](https://github.com/vicperdana/aznights-demo-feb-2022/actions/workflows/demo2.yaml/badge.svg)](https://github.com/vicperdana/aznights-demo-feb-2022/actions/workflows/demo2.yaml)


[![demo3-aznights-feb-2022](https://github.com/vicperdana/aznights-demo-feb-2022/actions/workflows/demo3.yaml/badge.svg)](https://github.com/vicperdana/aznights-demo-feb-2022/actions/workflows/demo3.yaml)

This repo demonstrates two use cases of Container Apps using [Dapr](https://dapr.io/) and [KEDA](https://keda.sh/). 

# Overview - Demo 1 + 2


<a href="https://docs.microsoft.com/en-us/azure/container-apps/microservices-dapr-azure-resource-manager?tabs=bash&pivots=container-apps-bicep"> <img src="https://docs.microsoft.com/en-us/azure/container-apps/media/microservices-dapr/azure-container-apps-microservices-dapr.png" alt="Container Apps architecture" width="500"/> </a>


The application consists of:

* A client (Python) container app to generate messages.
* A service (Node) container app to consume and persist those messages in a state store


## Verify the result

### Confirm successful state persistence

You can confirm that the services are working correctly by viewing data in your Azure Storage account.

1. Open the [Azure portal](https://portal.azure.com) in your browser and navigate to your storage account.

1. Select **Containers** from the menu on the left side.

1. Select **mycontainer**.

1. Verify that you can see the file named `order` in the container.

1. Select on the file.

1. Select the **Edit** tab.

1. Select the **Refresh** button to observe updates.

### View Logs

Data logged via a container app are stored in the `ContainerAppConsoleLogs_CL` custom table in the Log Analytics workspace. You can view logs through the Azure portal or from the command line. Wait a few minutes for the analytics to arrive for the first time before you query the logged data.

Use the following command to view logs in bash or PowerShell.

#### Bash

```azurecli
az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'nodeapp' and (Log_s contains 'persisted' or Log_s contains 'order') | project ContainerAppName_s, Log_s, TimeGenerated | take 5" \
  --out table
```

# Overview - Demo 3

![Background app](/demo3-keda/backgroundapp.drawio.png)


Using Azure Container Apps allows you to deploy applications without requiring the exposure of public endpoints. By using Container Apps scale rules, the application can scale up and down based on the Azure Storage queue length. When there are no messages on the queue, the container app scales down to zero.

## Add messages to the Queue
```azurecli
for i in {1..7}
do
  az storage message put \
    --content "Hello Queue Reader App" \
    --queue-name "myqueue" \
    --connection-string $QUEUE_CONNECTION_STRING
done
```

## Verify the result

The container app runs as a background process. As messages arrive from the Azure Storage Queue, the application creates log entries in Log analytics. You must wait a few minutes for the analytics to arrive for the first time before you are able to query the logged data.

Run the following command to see logged messages. This command requires the Log analytics extension, so accept the prompt to install extension when requested.

#### Bash

```azurecli
az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'queuereader' and Log_s contains 'Message ID'" \
  --out table
```

## Maintainers

- [Vic Perdana](https://github.com/VicPerdana)

## License

This project is [licensed under the MIT License](license).

[license]: https://github.com/azuretar/Azure-ContainerApps-Demo/blob/master/LICENSE