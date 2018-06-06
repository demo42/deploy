# Creating the AKS Instance

Rather than track bash and powershell commands for Mac and Windows clients, the bash [Azure Cloud Shell](https://shell.azure.com) can be used.

Get the environment variables from [./envVars.md](./envVars.md)

```sh
az group create -n $RESOURCE_GROUP -l $LOCATION
az aks create -n $RESOURCE_GROUP -g $RESOURCE_GROUP -s Standard_D2_v2 -p acrdemo -k 1.9.6 
```