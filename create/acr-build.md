# Resources to create/configure ACR Tasks

Info on [ACR Tasks](https://aka.ms/acr/build)

## Web Build-Task

Builds the web front end of the app

## Web

```sh
az acr task create \
  --registry  $ACR_NAME \
  --name      demo42-web \
  --image     demo42/web:{{.Build.ID}} \
  --file      acr-task.yaml \
  --arg       REGISTRY_NAME=$REGISTRY_NAME \
  --context   $GIT_REPO_WEB \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --set-secret TENANT=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-tenant \
                         --query value -o tsv) \
  --set-secret SP=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-deploy-usr \
                         --query value -o tsv) \
  --set-secret PASSWORD=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-deploy-pwd \
                         --query value -o tsv) \
  --set CLUSTER_NAME=${DEMO_NAME}-${ENV_NAME} \
  --set CLUSTER_RESOURCE_GROUP=$RESOURCE_GROUP_ENV
```

## Quotes API 

Builds the back-end Quotes API

```sh
az acr task create \
  --registry $ACR_NAME \
  --name demo42-quotes-api \
  --image demo42/quotes-api:{{.Build.ID}} \
  --context $GIT_REPO_QUOTES \
  --file      acr-task.yaml \
  --arg       REGISTRY_NAME=$REGISTRY_NAME \
  --git-access-token $(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $GIT_TOKEN_NAME \
                         --query value -o tsv) \
  --set-secret TENANT=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-tenant \
                         --query value -o tsv) \
  --set-secret SP=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-deploy-usr \
                         --query value -o tsv) \
  --set-secret PASSWORD=$(az keyvault secret show \
                         --vault-name $AKV_NAME \
                         --name $ACR_NAME-deploy-pwd \
                         --query value -o tsv) \
  --set CLUSTER_NAME=${DEMO_NAME}-${ENV_NAME} \
  --set CLUSTER_RESOURCE_GROUP=$RESOURCE_GROUP_ENV
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

## Notes

```sh
kubectl create secret docker-registry acr-auth --docker-server demo42.azurecr-test.io --docker-username $ACR_DF_PULL_USR --docker-password $ACR_DF_PULL_PWD --docker-email not-needed@foo-bar.com
```
