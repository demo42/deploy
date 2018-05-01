#!/bin/bash
set -e
while getopts ':r:s:' arg; do
    case ${arg} in
        s)
            _sdk=1
            ;;
        \? )
            echo "Usage: cmd [-h] [-t]"
            echo rebuilds the base image, setting build-args
            echo will always update the runtime, pass -s to update the sdk as well
            e2cho Parameters
            echo "   -r update the runtime base image"

            exit

            ;;
    esac
done

# default base image version to 2.1
if [ -z $_base_image_version ]
then
    _base_image_version=2.1
fi

if [ -z $_registry_name ]
then
    _registry_name=$REGISTRY_NAME

    if [ -z $_registry_name ]
    then
        echo ERROR: REGISTRY_NAME environment variable required eg: jengademos.azurecr.io/
        exit
    fi
fi
echo "DOTNET_VERSION: "$_base_image_version
echo "REGISTRY:       "$_registry_name

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/sdk
echo $PWD

_new_image=${_registry_name}baseimages/microsoft/dotnet-sdk:linux-${_base_image_version}
echo $_new_image
docker build \
  -f ./Dockerfile \
  -t $_new_image \
  --build-arg REGISTRY_NAME=$REGISTRY_NAME \
  --build-arg IMAGE_BUILD_DATE=`date +%Y%m%d-%H%M%S` \
   .
docker push $_new_image
