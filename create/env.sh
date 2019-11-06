#!/bin/sh

# Replace [these] values for your configuration
# I've left our values in, as we use this for our demos, providing some examples
# run source ./env.sh

# Base values
export DEMO_NAME=demo42
export LOCATION=southcentralus
export LOCATION_TLA=scus
export ENV_NAME=dev
# Global Resources
export RESOURCE_GROUP=$DEMO_NAME-${LOCATION_TLA}
# Environmental Specific Resoruces
export RESOURCE_GROUP_ENV=$DEMO_NAME-$ENV_NAME-${LOCATION_TLA}

# ACR
export ACR_NAME=${DEMO_NAME}t
export REGISTRY_NAME=${ACR_NAME}.azurecr.io/ 
export RESOURCE_GROUP_ACR=$ACR_NAME

# AKS
export AKS_NAME=${DEMO_NAME}-${ENV_NAME}

#Key Vault
export AKV_NAME=$DEMO_NAME

# SQL Server
export SQL_USER=demo42user
export SQL_PASSWORD="sdlkf12@alarua$"

#GitHub
export GIT_REPO_WEB="https://github.com/demo42/web.git"
export GIT_REPO_QUEUEWORKER="https://github.com/demo42/queueworker.git"
export GIT_REPO_QUOTES="https://github.com/demo42/quotes.git"
export GIT_TOKEN_NAME=${DEMO_NAME}-git-token
export PAT=[PAT]

if [ -n $ENV_NAME ]
then
    export HOST=demo42-${ENV_NAME}.${LOCATION}.cloudapp.azure.com
else
    export HOST=demo42.${LOCATION}.cloudapp.azure.com
fi
