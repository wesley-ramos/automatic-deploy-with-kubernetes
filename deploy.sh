#!/bin/bash

# Wesley Ramos <wesley-ramos-de-paula@hotmail.com>
#
# Info: Responsible for managing the deploy process.
# ==================================================================================================
#

function start_deploy_process() {

  if [[ $FORCE == 'true' ]];
    then
        delete_deployment_kubernetes
        delete_configuration_file
  fi

  deploy_configuration_exists=$( check_configuration_file_exists )

  if [[ $deploy_configuration_exists == 'false' ]];
    then
      generate_configuration_file
    else
      update_configuration_file
  fi

  start_deploy_in_kubernetes
}
