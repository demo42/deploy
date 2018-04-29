# Creating the AKS Instance

## East US
```sh
az group create -n acrdemoaks -l eastus
az aks create -n acrdemoeus -g acrdemoaks -s Standard_D2_v2 -p acrdemo -k 1.9.6 
```
## West Europe
```sh
az group create -n acrdemoaksweu -l westeurope
az aks create -n acrdemoweu -g acrdemoaksweu -s Standard_D2_v2 -p acrdemo -k 1.9.6 
```