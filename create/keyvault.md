# Azure Keyvault Creation

```sh
# Replace these values for your configuration
# I've left our values in, as we use this for our demos, providing some examples
```

- Create the KeyVault w/a new resource group

    ```sh
    az group create -n $RESOURCE_GROUP --location eastus
    az keyvault create --resource-group $RESOURCE_GROUP --name $AKV_NAME
    ```

## Save some keys we'll use

