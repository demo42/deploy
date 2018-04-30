# Resources to create/configure ACR Build
Info on [ACR Build](https://aka.ms/acr/build)

## Web Build-Task
Builds the web front end of the app
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
```

```sh
az acr build-task create \
  -n demo42web \
  --context https://github.com/demo42/web \
  -t demo42/quotes-api:{{.Build.ID}} \
  -f ./src/QuoteService/Dockerfile \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```

## Quotes API - w/CONNECTIONSTRING - East US
Builds the back-end Quotes API
Until I get the secret configured properly, I'm injecting the database password into the image - ***bad panda***
```sh
az acr build-task create \
  -n demo42quotesapi \
  --context https://github.com/demo42/quotes -t demo42/quotes-api:{{.Build.ID}} \
  -f ./src/WebUI/Dockerfile \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --secret-build-arg A_CONNECTIONSTRING=$(az keyvault secret show \
                                         --vault-name $AKV_NAME \
                                         --name demo42-quotes-sql-connectionstring-eastus \
                                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```
## Quotes API - w/CONNECTIONSTRING - WestEurope
***Temporary*** until passwords can be moved to kubernetes secrets. 
The only difference here is the keyvault secret for the database

```sh
az acr build-task create \
  -n demo42quotesapi \
  --context https://github.com/demo42/quotes -t demo42/quotes-api:{{.Build.ID}} \
  -f ./src/QuoteService/Dockerfile \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --secret-build-arg A_CONNECTIONSTRING=$(az keyvault secret show \
                                         --vault-name $AKV_NAME \
                                         --name demo42-quotes-sql-connectionstring-westeu \
                                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```
  
## ACR Webhoks
These are some snippets, that aren't *yet* scripted out
However, here's the list of webhooks used:
```
az acr webhook list
NAME                   RESOURCE GROUP    LOCATION    STATUS    SCOPE                ACTIONS
---------------------  ----------------  ----------  --------  -------------------  ---------
demo42QuotesApiEastus  jengademos        eastus      enabled   demo42/quotes-api:*  ['push']
demo42WebEastus        jengademos        eastus      enabled   demo42/web:*         ['push']
demo42QuotesApiWestEU  jengademos        westeurope  enabled   demo42/quotes-api:*  ['push']
demo42WebWestEU        jengademos        westeurope  enabled   demo42/web:*         ['push']
```
```sh
az acr webhook create \
  -r $ACR_NAME \
  --scope demo42/web:* \
  --actions push \
  --name demo42QuotesApiEastus \
  --headers Authorization=$(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name demo42-webhook-auth-header \
                            --query value -o tsv) \
  --uri http://http://jengajenkins.eastus.cloudapp.azure.com//jenkins/generic-webhook-trigger/invoke
```