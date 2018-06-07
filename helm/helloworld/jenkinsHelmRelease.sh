#!/bin/bash
# Script used in Jenkins to do a Helm Upgrade
# Presumes the path to KUBECONFIG has been set to the active cluster
# In a multi-geo deployment, each jenkins job would set this to it's region, in the release defintion
# export KUBECONFIG=/home/stevelas/k8s-configs/acrdemoeus

echo REGISTRY:$REGISTRY
echo REPOSITORY:$REPOSITORY
echo TAG:$TAG
pwd
case $REPOSITORY in
  demo42/helloworld*)
    echo helm upgrade helloworld ./helm/helloworld/ --reuse-values --set helloworld.image=$REGISTRY/$REPOSITORY:$TAG 
    helm upgrade helloworld ./helm/helloworld/ --reuse-values --set helloworld.image=$REGISTRY/$REPOSITORY:$TAG 

  ;;
  *)
    echo helm upgrade helloworld ./release/helm/ --reuse-values 
    helm upgrade helloworld ./release/helm/ --reuse-values
  ;;
esac