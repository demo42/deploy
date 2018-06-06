# Resources to create/configure ACR Build
Info on [ACR Build](https://aka.ms/acr/build)

## Web Build-Task
Builds the web front end of the app
 Common Environment Variables
```sh
# Replace these values for your configuration
# I've left our values in, as we use this for our demos, providing some examples
export ACR_NAME=demo42
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
  -n basedotnetsdk \
  --context https://github.com/demo42/deploy \
  -t baseimages/microsoft/dotnet-sdk:linux-2.1 \
  --cpu 2 \
  -f ./baseImage/sdk/Dockerfile \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```


```sh
BRANCH=master
az acr build-task create \
  -n demo42web \
  --context https://github.com/demo42/web \
  -t demo42/web:{{.Build.ID}} \
  --cpu 2 \
  --branch $BRANCH \
  -f ./src/WebUI/Dockerfile \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```

## Quotes API 
Builds the back-end Quotes API
```sh
BRANCH=master
az acr build-task create \
  -n demo42queueworker \
  --context https://github.com/demo42/quotes \
  -t demo42/quotes-api:{{.Build.ID}} \
  -f ./src/QuoteService/Dockerfile \
  --cpu 2 \
  --branch $BRANCH \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```

## QueueWorker
Builds the demo42/queueworker image that pulls "important" stuff off the queue and saves it to the unlreiable backend system
```sh
BRANCH=master
az acr build-task create \
  -n demo42queueworker \
  --context https://github.com/demo42/queueworker \
  -t demo42/queueworker:{{.Build.ID}} \
  -f ./src/Important/Dockerfile \
  --cpu 2 \
  --branch $BRANCH \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${GIT_TOKEN_NAME} \
                         --query value -o tsv) \
  --registry $ACR_NAME 
  ```

## BaseImages

- dotnet runtime
  ```sh
  az acr build-task create \
    -n baseimagaspnetcoreruntime \
    -c https://github.com/demo42/baseimage-aspnetcoreruntime \
    -t baseimages/microsoft/aspnetcore-runtime:linux-2.1 \
    --cpu 2 \
    --build-arg REGISTRY_NAME=$REGISTRY_NAME \
    --git-access-token $(az keyvault secret show \
                          --vault-name $AKV_NAME \
                          --name $GIT_TOKEN_NAME \
                          --query value -o tsv) \
    --registry $ACR_NAME
  ```

- aspnetcore sdk
  ```sh
  az acr build-task create \
    -n baseimagedotnetsdk \
    -c https://github.com/demo42/baseimge-dotnet-sdk\
    -t baseimages/microsoft/dotnet-sdk:linux-2.1 \
    --cpu 2 \
    --build-arg REGISTRY_NAME=$REGISTRY_NAME \
    --git-access-token $(az keyvault secret show \
                          --vault-name $AKV_NAME \
                          --name $GIT_TOKEN_NAME \
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

