#!/bin/bash
# Script used in Jenkins to do a Helm Upgrade
export KUBECONFIG=/home/stevelas/k8s-configs/acrdemoeus

echo REGISTRY:$REGISTRY
echo REPOSITORY:$REPOSITORY
echo TAG:$TAG
pwd
case $REPOSITORY in
  demo42/web*)
    echo helm upgrade demo42 ./Helm/ --reuse-values --set web.image=$REGISTRY/$REPOSITORY:$TAG 
    helm upgrade demo42 ./Helm/ --reuse-values --set web.image=$REGISTRY/$REPOSITORY:$TAG 
  ;;
  demo42/quotes-api*)
    echo helm upgrade demo42 ./Helm/ --reuse-values --set api.image=$REGISTRY/$REPOSITORY:$TAG
    helm upgrade demo42 ./Helm/ --reuse-values --set api.image=$REGISTRY/$REPOSITORY:$TAG
  ;;
  *)
    echo helm upgrade demo42 . --reuse-values 
    helm upgrade demo42 ./Helm/ --reuse-values
  ;;
esac
