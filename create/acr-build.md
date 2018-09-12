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
## Web

** preview api **
```sh
BRANCH=master
az acr build-task create \
  -n demo42web \
  --context https://github.com/demo42/web \
  -t demo42/web:{{.Build.ID}} \
  --branch $BRANCH \
  -f ./src/WebUI/Dockerfile \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
```

** GA Api dockerfile
```sh
BRANCH=master
az acr task create \
  -n demo42-web \
  --context https://github.com/demo42/web \
  -t demo42/web:{{.Build.ID}} \
  --branch $BRANCH \
  -f ./src/WebUI/Dockerfile \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
```

** Task Preview 
```sh
BRANCH=master
az acr task create \
  -n demo42-web \
  --file acr-task.yaml \
  --context https://github.com/demo42/web \
  --branch $BRANCH \
  --set-secret TENANT=72f988bf-86f1-41af-91ab-2d7cd011db47 \
  --set-secret SP=0b161bb5-d504-479b-b11b-a4d5eddfbb22 \
  --set-secret PASSWORD=0968c6cc-59ae-4938-908e-9dd317683a2e \
  --set CLUSTER_NAME=demo42-staging-eus \
  --set CLUSTER_RESOURCE_GROUP=demo42-staging-eus \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
```
```sh
az acr task create \
  -n demo42-web \
  --file acr-task.yaml \
  --context https://github.com/demo42/web.git \
  --branch $BRANCH \
  --set-secret TENANT=$TENANT \
  --set-secret SP=$SP \
  --set-secret PASSWORD=$PASSWORD \
  --set CLUSTER_NAME=demo42-staging-eus \
  --set CLUSTER_RESOURCE_GROUP=demo42-staging-eus \
  --set-secret REGISTRY_USR=$ACR_PULL_USR \
  --set-secret REGISTRY_PWD=$ACR_PULL_PWD \
  --git-access-token ${GIT_TOKEN} \
  --registry $ACR_NAME 
```

```sh
kubectl create secret docker-registry acr-auth --docker-server demo42.azurecr-test.io --docker-username $ACR_DF_PULL_USR --docker-password $ACR_DF_PULL_PWD --docker-email not-needed@foo-bar.com
```

## Quotes API 
Builds the back-end Quotes API
** Preview API **
```sh
BRANCH=master
az acr build-task create \
  -n demo42quotesapi \
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

** GA API
```sh
BRANCH=master
az acr task create \
  -n demo42-quotes-api \
  --context https://github.com/demo42/quotes \
  -t demo42/quotes-api:{{.Build.ID}} \
  -f ./src/QuoteService/Dockerfile \
  --branch $BRANCH \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --registry $ACR_NAME 
```

## QueueWorker
Builds the demo42/queueworker image that pulls "important" stuff off the queue and saves it to the unreliable backend system

** Preview API **
```sh
BRANCH=master
az acr build-task create \
  -n demo42queueworker \
  --context https://github.com/demo42/queueworker \
  -t demo42/queueworker:{{.Build.ID}} \
  -f ./src/Important/Dockerfile \
  --branch $BRANCH \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${GIT_TOKEN_NAME} \
                         --query value -o tsv) \
  --registry $ACR_NAME 
```

** GA API **
```sh
BRANCH=master
az acr task create \
  -n demo42-queueworker \
  --context https://github.com/demo42/queueworker \
  -t demo42/queueworker:{{.Build.ID}} \
  -f ./src/Important/Dockerfile \
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
    --build-arg REGISTRY_NAME=$REGISTRY_NAME \
    --git-access-token $(az keyvault secret show \
                          --vault-name $AKV_NAME \
                          --name $GIT_TOKEN_NAME \
                          --query value -o tsv) \
    --registry $ACR_NAME
  ```

```sh
az acr task create \
  -n demo42-deploy \
  --context https://github.com/demo42/queueworker \
  -t demo42/queueworker:{{.Build.ID}} \
  -f ./src/Important/Dockerfile \
  --branch $BRANCH \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${GIT_TOKEN_NAME} \
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
  --uri http://40.121.67.160:8080/jenkins/generic-webhook-trigger/invoke
```

