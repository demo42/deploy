# Helm Chart Creation and Updates

Used when I manually run helm charts for testing. A version of this is configured through jenkins

## Environment Variables
    see [envVars](./envVars.md)

## Install

On first install, replace the top line of upgrade, with this install line:
```sh

helm install ./helm/ -n demo42-$ENV_NAME \
```
## Upgrade
```sh
helm upgrade demo42 ./helm/ \
--reuse-values \
helm install ./helm/ -n demo42-$ENV_NAME \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:aa9j \
--set quotesApi.image=${REGISTRY_NAME}demo42/quotes-api:aa9k \
--set queueworker.image=${REGISTRY_NAME}demo42/queueworker:aa9f \
--set StorageConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name ${DEMO_NAME}-${ENV_NAME}-StorageConnectionString-${LOCATION_TLA} \
                            --query value -o tsv) \
--set ConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name ${DEMO_NAME}-${ENV_NAME}-quotes-sql-connectionstring-${LOCATION_TLA} \
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
- Integration Deployment
```sh
export HOST=demo42-int.eastus.cloudapp.azure.com
helm install ./helm/ -n demo42-int \
helm upgrade demo42 ./helm/ \
--reuse-values \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:aa9j \
--set quotesApi.image=${REGISTRY_NAME}demo42/quotes-api:aa9k \
--set queueworker.image=${REGISTRY_NAME}demo42/queueworker:aa9f \
--set StorageConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-StorageConnectionString-westeu \
                            --query value -o tsv) \
--set ConnectionString=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-quotes-sql-connectionstring-westeu \
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
