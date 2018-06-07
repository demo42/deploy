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
helm upgrade demo42-$ENV_NAME ./helm/ \
--reuse-values \
helm install ./helm/ -n demo42 \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:aag \
--set quotesApi.image=${REGISTRY_NAME}demo42/quotes-api:aae \
--set queueworker.image=${REGISTRY_NAME}demo42/queueworker:aaf \
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
