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
--set StorageConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-StorageConnectionString-eastus \
                            --query value -o tsv) \
--set ConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-quotes-sql-connectionstring-eastus \
                            --query value -o tsv) \
--set StorageConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-StorageConnectionString-eastus \
                            --query value -o tsv) \
--set QueueName=important \
--set imageCredentials.registry=$ACR_NAME.azurecr.io \
--set imageCredentials.username=$(az keyvault secret show \
                                    --vault-name $AKV_NAME \
                                    --name $ACR_NAME-pull-usr \
                                    --query value -o tsv) \
--set imageCredentials.password=$(az keyvault secret show \
                                    --vault-name $AKV_NAME \
                                    --name $ACR_NAME-pull-pwd \
                                    --query value -o tsv)
```

helm upgrade demo42 ./helm/ \
--reuse-values \
--set ConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-quotes-sql-connectionstring-eastus \
                            --query value -o tsv) \
--set StorageConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-StorageConnectionString-eastus \
                            --query value -o tsv) \
--set QueueName=important 
--set queueworker.replicas = 1
