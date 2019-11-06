# Demo42 - Geo-replicated, ACR Build, Keyvault, Helm, AKS, AspDotNet Demo

A demo used for Microsoft Build 2018 that incorporates
- [Azure Container Registry - (ACR)](https://aka.ms/acr)
- [ACR Build - a native container build service provding OS & Framework patching primtives](https://aka.ms/acr/build)
- [ACR Geo-replication](https://aka.ms/acr/geo-replication) enabling a single deployment, servicing two continents
- [Azure Keyvault](https://azure.microsoft.com/services/key-vault/), securing credential information
- [Helm](https://helm.sh/): managing deployments to Kubernetes
- [Jenkins](https://jenkins.io/): used for release management of ACR Built images, deployed with Helm to Kubernetes
- [Azure Kubernetes Service](https://azure.microsoft.com/services/container-service/): providing a managed Kubernetes offering
- [Asp.net Core](https://asp.net): an open source web framework for building modern web apps and services 

We've tried to follow best practices for:
- extracting configuration from your images
- extracting secrets to kubernets secret storage within AKS, and azure keyvault for storage before provisioning
- unique tagging for deployments - see: [Docker Tagging: Best practices for tagging and versioning docker images](https://blogs.msdn.microsoft.com/stevelasker/2018/03/01/docker-tagging-best-practices-for-tagging-and-versioning-docker-images/)

## Related Repos

- [Deploy](https://github.com/demo42/deploy): This repo, used for managing the Helm Chart Deployments
  - this repos also inlcudes the scripts required to create the various resources in Azure
- [Web](https://github.com/demo42/web): The front end website
- [Quotes](https://github.com/demo42/quotes): An API Service, used to return random quotes, demonstrating a non-critical service

## Creating Resources

- [Creating resources](./create/README.md)

## Demo Commands

```sh
ACR_NAME=demo42
az acr task create \
  -n demo42-deploy \
  --file acr-task.yaml \
  --context https://github.com/demo42/deploy.git \
  --set-secret TENANT=$(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-serviceaccount-tenant \
            --query value -o tsv) \
  --set-secret SP=$(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-serviceaccount-user \
            --query value -o tsv) \
  --set-secret PASSWORD=$(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-serviceaccount-pwd \
            --query value -o tsv) \
  --set CLUSTER_NAME=demo42-staging-eus \
  --set CLUSTER_RESOURCE_GROUP=demo42-staging-eus \
  --set-secret REGISTRY_USR=$(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-pull-usr \
            --query value -o tsv) \
  --set-secret REGISTRY_PWD=$(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-pull-pwd \
            --query value -o tsv) \
  --git-access-token $(az keyvault secret show \
            --vault-name ${AKV_NAME} \
            --name demo42-git-token \
            --query value -o tsv) \
  --registry $ACR_NAME 

```
Run the scheduled task
```sh
az acr task run -n demo42-web
```