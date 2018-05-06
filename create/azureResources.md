
## East US Int Environment
- Environment Variables
    see [envVars](./envVars.md)
- Resource Groups
    ```sh
    az group create -n $RESOURCE_GROUP -l $LOCATION
    az group create -n $RESOURCE_GROUP_REGION -l $LOCATION
    ```

- Storage Accounts
    ```sh
    az storage account create \
        -n demo42${ENV_NAME}${LOCATION_TLA} \
        -g $RESOURCE_GROUP
    ```

- Storage Queue in West Europe
    ```sh
    az storage queue create \
        -n important \
        --account-name demo42${ENV_NAME}${LOCATION_TLA}
    ```
- SQL Server Database
    ```sh
    az sql server create \
        -n ${DEMO_NAME}-${LOCATION_TLA} \
        -u $SQL_USER \
        -p $SQL_PASSWORD \
        -l $LOCATION \
        -g $RESOURCE_GROUP_REGION

    az sql db create \
        -n Quotes-$ENV_NAME \
        -s ${DEMO_NAME}-${LOCATION_TLA} \
        -g $RESOURCE_GROUP_REGION
    ```

## Azure KeyVault
    ```sh
    az keyvault create --resource-group $RESOURCE_GROUP --name $AKV_NAME
    ```

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
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name $GIT_TOKEN_NAME \
        --value $PAT
    ```

- SQL Database Connection
    ```sh
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name ${DEMO_NAME}-${ENV_NAME}-quotes-sql-connectionstring-${LOCATION_TLA} \
        --value "Server=$(az sql server show \
                    -n $DEMO_NAME-${LOCATION_TLA} \
                    -g $RESOURCE_GROUP_REGION \
                    --query fullyQualifiedDomainName -o tsv);Database=Quotes-$ENV_NAME;User=${SQL_USER};Password=${SQL_PASSWORD};"


- Storage Connection String
    ```sh
    az keyvault secret set \
        --vault-name $AKV_NAME \
        --name ${DEMO_NAME}-${ENV_NAME}-StorageConnectionString-${LOCATION_TLA} \
        --value $(az storage account show-connection-string \
                   -n demo42${ENV_NAME}${LOCATION_TLA} \
                   -g $RESOURCE_GROUP -o tsv)
    ```



