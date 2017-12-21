#!/bin/bash

# Wesley Ramos <wesley-ramos-de-paula@hotmail.com>
#
# Info: Script developed with the purpose of facilitating the deploy of a new microservice.
# ==================================================================================================
#
# How to use:
#
# Param:
#  environment: Environment in which deploy will be executed.
#  name: Service Name.
#  image: Image of the application, service that will run in the container.
#  replicas: Number of service replicas.
#  host: Host of kubernetes
#  path: Service address.
#  force: Force deploy recreation
#
# Ex:
#   - Public services:
#      ./deploy.sh --environment=staging --name=my-service --image=image-of-my-service --replicas=1 --path=service-path --force=false
#
#   - Private services:
#     ./deploy.sh --environment=staging --name=my-service --image=image-of-my-service --replicas=1  --force=false
#
#


#
# Imports the necessary routines
#
source ./configuration_file.sh
source ./manager.sh


#
#  Populate with the default value
#

REPLICAS=1
FORCE="false"

#
# Reads the parameters
#

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F"=" '{print $1}'`
  VALUE=`echo $1 | awk -F"=" '{print $2}'`
  case $PARAM in
    -n | --name)
      APPLICATION_NAME=$VALUE
      ;;
    -e | --environment )
      ENVIRONMENT_NAME=$VALUE
      ;;
    -i | --image)
      IMAGE=$VALUE
      ;;
    -r | --replicas)
      REPLICAS=$VALUE
      ;;
    -p | --path)
      PATH=$VALUE
      ;;
    -f | --force)
      FORCE=$VALUE
      ;;
    *)
    echo "it was not possible to read the parameters"
    exit 1
    ;;
  esac
  shift
done

#
# Validates required fields
#

if [[ -z "$ENVIRONMENT_NAME" ]]; then
  echo "Environment not set, please set --environment"
  exit 1
elif [[  -z "$APPLICATION_NAME" ]]; then
  echo "Application name not set, please set --name"
  exit 1
elif [[ -z "$IMAGE" ]]; then
  echo "Application image not set, please set --image"
  exit 1
fi

#
#  Starts the deploy process
#
start_deploy_process
