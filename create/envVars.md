
# Parameters used for az cli commands
Used for most of the scripts here

```sh
export DEMO_NAME=demo42

export LOCATION_TLA=eus
export LOCATION=eastus
export ENV_NAME=staging
export RESOURCE_GROUP=$DEMO_NAME-$ENV_NAME-${LOCATION_TLA}
export RESOURCE_GROUP_REGION=$DEMO_NAME-${LOCATION_TLA}

export AKV_NAME=$DEMO_NAME

export SQL_USER=demo42user
export SQL_PASSWORD=[pwd]

export ACR_NAME=$DEMO_NAME
# fully qualified url of the registry. 
export REGISTRY_NAME=${ACR_NAME}.azurecr.io/ 

export GIT_TOKEN_NAME=stevelasker-git-access-token # keyvault secret name
export PAT=#[git token]


if [ -n $ENV_NAME ]
then
    export HOST=demo42-${ENV_NAME}.${LOCATION}.cloudapp.azure.com
else
    export HOST=demo42.${LOCATION}.cloudapp.azure.com
fi
```