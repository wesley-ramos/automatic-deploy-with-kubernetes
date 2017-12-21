#!/bin/bash

# Wesley Ramos <wesley-ramos-de-paula@hotmail.com>
#
# Info: Responsible for managing the deploy process.
# ==================================================================================================
#

function start_deploy_process() {
  deploy_configuration_exists=$( check_configuration_file_exists )

  if [[ $deploy_configuration_exists == 'false' ]];
     then
      generate_configuration_file
  fi
}
