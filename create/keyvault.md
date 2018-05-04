# Azure Keyvault Creation

```sh
# Replace these values for your configuration
# I've left our values in, as we use this for our demos, providing some examples
export ACR_NAME=jengademos
export RESOURCE_GROUP=$ACR_NAME
export REGISTRY_NAME=${ACR_NAME}.azurecr.io/ 
export AKV_NAME=$ACR_NAME-vault # name of the keyvault
export GIT_TOKEN_NAME=stevelasker-git-access-token # keyvault secret name
```

- Create the KeyVault w/a new resource group

    ```sh
    az group create -n $RESOURCE_GROUP --location eastus
    az keyvault create --resource-group $RESOURCE_GROUP --name $AKV_NAME
    ```

## Save some keys we'll use

- Registry Service Principal Username/Password
    ```sh
    az keyvault secret set \
      --vault-name $AKV_NAME \
      --name $ACR_NAME-pull-pwd \
      --value $(az ad sp create-for-rbac \
                --name $ACR_NAME-pull \
                --scopes $(az acr show --name $ACR_NAME --query id --output tsv) \
                --role reader \
                --query password \
                --output tsv)

    # Store service principal ID in AKV (the registry *username*)
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name $ACR_NAME-pull-usr \
        --value $(az ad sp show --id http://$ACR_NAME-pull --query appId --output tsv)
    ```

- Github Personal Access Token
    
    Create a PAT in github, and save the value here:
    ```sh
    PAT=[value from github]
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name $GIT_TOKEN_NAME \
        --value $PAT
    ```
- SQL Database Connection

    ```sh
    CONNECTIONSTRING_EASTUS=[SQL ConnectionString]
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name demo42-quotes-sql-connectionstring-eastus \
        --value $CONNECTIONSTRING_EASTUS

    STORAGECONNECTIONSTRING_EASTUS=[ Storage Connection String]
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name demo42-StorageConnectionString-eastus \
        --value $STORAGECONNECTIONSTRING_EASTUS

    CONNECTIONSTRING_WESTEU=[SQL ConnectionString]
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name demo42-quotes-sql-connectionstring-westeu \
        --value $CONNECTIONSTRING_WESTEU

    STORAGECONNECTIONSTRING_WESTEU=[ Storage Connection String]
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name demo42-StorageConnectionString-westeu \
        --value $STORAGECONNECTIONSTRING_WESTEU

    ```

