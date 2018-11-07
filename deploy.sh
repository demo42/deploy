#!/bin/sh

set -e
# SP, PASSWORD , CLUSTER_NAME, CLUSTER_RESOURCE_GROUP
az configure --defaults acr=$REGISTRY_NAME

az login \
    --service-principal \
    --username $SP \
    --password $PASSWORD \
    --tenant $TENANT  > /dev/null

echo -- helm init --client-only --
helm init --client-only > /dev/null

echo -- az acr helm repo add --
az acr helm repo add 

echo -- helm package --
helm package \
    --version $APP_VERSION \
    --app-version {{.Run.ID}} \
    ./helm/importantThings

echo -- az acr helm push --
az acr helm push \
    ./importantThings-1.0.0.tgz \
    --force -o table


