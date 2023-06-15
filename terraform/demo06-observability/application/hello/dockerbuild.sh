#!/bin/bash

get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

if [ ! -z "$1" ]
then
      echo "\$1 is NOT empty - $1"
      export DOCKER_IMAGE_VERSION="$1"
else
      echo "\$1 is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

aws ecr get-login-password --region $CURRENT_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com
docker build . -t grafana-demo-hello:latest
docker tag grafana-demo-hello:latest $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-hello:$DOCKER_IMAGE_VERSION
docker push $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-hello:$DOCKER_IMAGE_VERSION
