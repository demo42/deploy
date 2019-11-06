# Base Azure Resources

These are the base Azure Resources to get the script started. Including:

## Environment Variables

see [envVars](./envVars.md)

## Resource Groups

```sh
az group create -n $RESOURCE_GROUP -l $LOCATION
az group create -n $RESOURCE_GROUP_ENV -l $LOCATION
```

## Registry

```sh
az group create -n $RESOURCE_GROUP_ACR -l $LOCATION
az acr create -n $ACR_NAME -l $LOCATION -g $RESOURCE_GROUP_ACR --sku premium
```

## Storage

- Storage Account

  ```sh
  az storage account create \
    -n ${DEMO_NAME}${ENV_NAME}${LOCATION_TLA} \
    -g $RESOURCE_GROUP_ENV
  ```

- Storage Queue

  ```sh
  az storage queue create \
    -n important \
    --account-name ${DEMO_NAME}${ENV_NAME}${LOCATION_TLA}
  ```

## Azure KeyVault

- Create the KeyVault

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

- Storage Connection String

  ```sh
  az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-${ENV_NAME}-StorageConnectionString-${LOCATION_TLA} \
    --value $(az storage account show-connection-string \
              -n ${DEMO_NAME}${ENV_NAME}${LOCATION_TLA} \
              -g $RESOURCE_GROUP_ENV -o tsv)
  ```

- SQL User & Password

  ```sh
  az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-${ENV_NAME}-SQLuser \
    --value $SQL_USER

  az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-${ENV_NAME}-SQLpwd \
    --value $SQL_PASSWORD
  ```

## SQL Server Database

- Create the server & db

  ```sh
  az sql server create \
    -n ${DEMO_NAME}-westus2-SQL \
    -u $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name ${DEMO_NAME}-${ENV_NAME}-SQLuser \
                         --query value -o tsv) \
    -p $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name ${DEMO_NAME}-${ENV_NAME}-SQLpwd \
                         --query value -o tsv) \
    -l westus2 \
    -g $RESOURCE_GROUP_ENV

    az sql db create \
        -s ${DEMO_NAME}-westus2-SQL \
        -n Quotes-$ENV_NAME \
        -g $RESOURCE_GROUP_ENV
    ```

- Save the SQL Database Connection to KeyVault

  ```sh
  az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-${ENV_NAME}-quotes-sql-connectionstring \
    --value "Server=$(az sql server show \
              -n ${DEMO_NAME}-westus2-SQL \
              -g $RESOURCE_GROUP \
              --query fullyQualifiedDomainName -o tsv);Database=Quotes-$ENV_NAME;User=${SQL_USER};Password=${SQL_PASSWORD};"
  ```

## Azure Kubernetes Service

Created via the portal for now

```sh
#az aks create -n $AKS_NAME -g $RESOURCE_GROUP_ENV -s Standard_D2_v2 -p acrdemo -k 1.9.6
```

## Credentials

To perform an AKS update using Helm, a service principal is required to pull images from the registry and execute `helm update`. To avoid losing the credentials, while storing them securely, we'll create a service principal, saving the secrets to Azure Key Vault

```sh
# Create a service principal (SP) with:
# - registry pull permissions
# - cluster deploy permissions

# Create a SP with registry pull permissions, saving the created password to a Key Vault secret.
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name $ACR_NAME-deploy-pwd \
  --value $(az ad sp create-for-rbac \
            --name $ACR_NAME-deploy \
            --scopes \
              $(az acr show \
                --name $ACR_NAME \
                --query id \
                --output tsv) \
            --role reader \
            --query password \
            --output tsv)

# Store the service principal ID, (username) in Key Vault
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-deploy-usr \
    --value $(az ad sp show \
              --id http://$ACR_NAME-deploy \
              --query appId --output tsv)

# Assign permissions required for Helm Update
az role assignment create \
  --assignee $(az ad sp show \
              --id http://$ACR_NAME-deploy \
              --query appId \
              --output tsv) \
  --role owner \
  --scope $(az aks show \
              --resource-group $RESOURCE_GROUP_ENV \
              --name ${DEMO_NAME}-${ENV_NAME} \
              --query "id" \
              --output tsv)

# Save the tenant for az login --service-principal
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name $ACR_NAME-tenant \
    --value $(az account show \
              --query tenantId \
              -o tsv)
```
