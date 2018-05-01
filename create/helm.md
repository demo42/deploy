# Helm Chart Creation and Updates

Used when I manually run helm charts for testing. A version of this is configured through jenkins

## Install
To switch between EastUS and West Europe instances, set the following env vars:
 Common Environment Variables
```sh
# Replace these values for your configuration
# I've left our values in, as we use this for our demos, providing some examples
export ACR_NAME=jengademos
export RESOURCE_GROUP=$ACR_NAME
# fully qualified url of the registry. 
# This is where your registry would be
# Accounts for registries in dogfood or other clouds like .gov, Germany and China
export REGISTRY_NAME=${ACR_NAME}.azurecr.io/ 
export AKV_NAME=$ACR_NAME-vault # name of the keyvault
export GIT_TOKEN_NAME=stevelasker-git-access-token # keyvault secret name
# eastus
export HOST=demo42.eastus.cloudapp.azure.com
# westeu
export HOST=demo42.westeurope.cloudapp.azure.com
```

On first install, replace the top line of upgrade, with this install line:
```sh
helm install ./helm/ -n demo42 \
```
## Upgrade
```sh
helm upgrade demo42 ./helm/ \
--reuse-values \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:$TAG \
--set api.image=${REGISTRY_NAME}demo42/quotes-api:$TAG \
--set dbConnectionString=$(az keyvault secret show \
                                         --vault-name $AKV_NAME \
                                         --name demo42-quotes-sql-connectionstring-eastus \
                                         --query value -o tsv) \
--set imageCredentials.registry=$ACR_NAME.azurecr.io \
--set imageCredentials.username=$(az keyvault secret show \
                                         --vault-name $AKV_NAME \
                                         --name $ACR_NAME-pull-usr \
                                         --query value -o tsv) \
--set imageCredentials.password=$(az keyvault secret show \
                                         --vault-name $AKV_NAME \
                                         --name $ACR_NAME-pull-pwd \
                                         --query value -o tsv)
docker login jengademos.azurecr.io -u 2cc69792-d663-4949-a702-5fb735090b07 -p 3c0a183b-f0b8-4cf2-8e9a-5b8f618498b1
docker pull jengademos.azurecr.io/baseimages/microsoft/dotnet-sdk:linux-2.1
docker pull jengademos.azurecr.io/baseimages/microsoft/aspnetcore-runtime:linux-2.1

helm upgrade demo42 ./helm/ \
--reset-values \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:$TAG \
--set api.image=${REGISTRY_NAME}demo42/quotes-api:$TAG \
--set dbConnectionString=$(az keyvault secret show \
                                         --vault-name $KEYVAULT \
                                         --name demo42-quotes-sql-connectionstring-eastus \
                                         --query value -o tsv)

```