# Helm Chart Creation and Updates

Used when I manually run helm charts for testing. A version of this is configured through jenkins

## Install
To switch between EastUS and West Europe instances, set the following env vars:
```sh
# DNS Name used for the NGINX load balancer
# EastUS
export HOST=demo42.eastus.cloudapp.azure.com
# WestEuope
export HOST=demo42.westeurope.cloudapp.azure.com
#TAG
export TAG=n1
```

On first install, replace the top line of upgrade, with this install line:
```sh
helm install . -n demo42 \
```
## Upgrade
```sh
helm upgrade demo42 . \
--reuse-values \
--set web.host=$HOST \
--set web.image=${REGISTRY_NAME}demo42/web:$TAG \
--set api.image=${REGISTRY_NAME}demo42/quotes-api:$TAG \
--set dbConnectionString=$(az keyvault secret show \
                                         --vault-name $KEYVAULT \
                                         --name demo42-quotes-sql-connectionstring-eastus \
                                         --query value -o tsv) \
--set imageCredentials.registry=$ACR_NAME.azurecr.io \
--set imageCredentials.username=$(az keyvault secret show \
                                         --vault-name $KEYVAULT \
                                         --name $ACR_NAME-pull-usr \
                                         --query value -o tsv) \
--set imageCredentials.password=$(az keyvault secret show \
                                         --vault-name $KEYVAULT \
                                         --name $ACR_NAME-pull-pwd \
                                         --query value -o tsv) \
```
