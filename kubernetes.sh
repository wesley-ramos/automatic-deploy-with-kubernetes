#!/bin/bash

# Wesley Ramos <wesley-ramos-de-paula@hotmail.com>
#
# Info:
# ==================================================================================================

function check_deployment_exists_in_kubernetes() {
  recover_deploys=`kubectl --namespace=${NAMESPACE} get deployments ${ENVIRONMENT_NAME}-${APPLICATION_NAME}`
  deploy_name=`echo $recover_deploys | cut -d " " -f7`

  if [[ $deploy_name == ${ENVIRONMENT_NAME}-${APPLICATION_NAME} ]];
     then
        echo "true"
     else
        echo "false"
  fi
}

function delete_deployment_kubernetes() {
  deployment_exists=$( check_deployment_exists_in_kubernetes )

  if [[ $deployment_exists == 'true' ]]; then
    kubectl --namespace=${NAMESPACE} delete -f ${CONFIGURATION_DIRECTORY}${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
  fi
}

function start_deploy_in_kubernetes() {
    deployment_exists=$( check_deployment_exists_in_kubernetes )

    if [[ $deployment_exists == 'true' ]];
       then
          kubectl --namespace=${NAMESPACE} set image deployment/${ENVIRONMENT_NAME}-${APPLICATION_NAME} ${ENVIRONMENT_NAME}-${APPLICATION_NAME}=$IMAGE
       else
          kubectl --namespace=${NAMESPACE} create -f ${CONFIGURATION_DIRECTORY}${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
    fi
}
