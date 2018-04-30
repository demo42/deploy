#!/bin/bash
set -e
while getopts ':v:r:' arg; do
    case ${arg} in
        v)
            _base_image_version=$OPTARG
            ;;
        r) 
            _registry_name=$OPTARG
            ;;
        \? )
            echo "Usage: cmd [-h] [-t]"
            echo Pulls the latest dotnet/aspnetcore images 
            echo Pushes to the -r specified registry
            echo Parameters
            echo "   -v version to pull"
            echo "   -r ACR Private registry [OPTIONAL - uses REGISTRY_NAME if not specified]"

            exit

            ;;
    esac
done
if [ -z $_registry_name ]
then
    _registry_name=$REGISTRY_NAME

    if [ -z $_registry_name ]
    then
        echo ERROR: -r required 
        exit
    fi
fi
echo "IMAGE:    "$_base_image_version
echo "REGISTRY: "$_registry_name

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ----------------------------
echo Pull/Tag/Push aspnetcore RUNTIME:${_base_image_version}
echo ----------------------------

docker pull microsoft/dotnet-nightly:${_base_image_version}-aspnetcore-runtime

_new_image=${_registry_name}baseimages/microsoft/aspnetcore-runtime:linux-${_base_image_version}

docker build \
  -f runtime/Dockerfile \
  -t $_new_image \
  --build-arg BASE_IMAGE_VERSION=${_base_image_version} \
  --build-arg IMAGE_BUILD_DATE=`date +%Y%m%d-%H%M%S` \
  .

docker push $_new_image

echo ----------------------------
echo Pull/Tag/Push dotnet SDK:${_base_image_version}
echo ----------------------------
docker pull microsoft/dotnet-nightly:${_base_image_version}-sdk

_new_image=${_registry_name}baseimages/microsoft/dotnet-sdk:linux-${_base_image_version}

docker build \
  -f sdk/Dockerfile \
  -t $_new_image \
  --build-arg BASE_IMAGE_VERSION=${_base_image_version} \
  --build-arg IMAGE_BUILD_DATE=`date +%Y%m%d-%H%M%S` \
  .
docker push $_new_image
