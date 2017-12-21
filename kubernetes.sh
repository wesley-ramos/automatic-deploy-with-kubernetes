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

function check_parameters() {
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
}

function check_deployment_exists_in_repository() {
  if [ -e "../deployments/${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml" ]
    then
      echo "true"
    else
      echo "false"
  fi
}

function create_file_deploy_internal() {
cat <<EOT > ./${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  namespace: ${ENVIRONMENT_NAME}
  labels:
    environment: ${ENVIRONMENT_NAME}
    application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      environment: ${ENVIRONMENT_NAME}
      application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  template:
    metadata:
      labels:
        environment: ${ENVIRONMENT_NAME}
        application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
    spec:
      containers:
        - name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
          image: "$IMAGE"
          imagePullPolicy: Always
          env:
            - name: SPRING_CLOUD_CONFIG_LABEL
              value: "$ENVIRONMENT_NAME"
      imagePullSecrets:
        - name: involvesregistry
EOT
}


function create_file_deploy_external() {
cat <<EOT > ./${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  namespace: ${ENVIRONMENT_NAME}
  labels:
    environment: ${ENVIRONMENT_NAME}
    application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      environment: ${ENVIRONMENT_NAME}
      application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  template:
    metadata:
      labels:
        environment: ${ENVIRONMENT_NAME}
        application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
    spec:
      containers:
        - name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
          image: "${IMAGE}"
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_CLOUD_CONFIG_LABEL
              value: "$ENVIRONMENT_NAME"
            - name: SERVER_PORT
              value: "8080"
      imagePullSecrets:
        - name: involvesregistry
---
apiVersion: v1
kind: Service
metadata:
  name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  namespace: ${ENVIRONMENT_NAME}
  labels:
    application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
spec:
  type: NodePort
  selector:
    application: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
  namespace: ${ENVIRONMENT_NAME}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/ssl-redirect: "true"
    ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - ${ENVIRONMENT_NAME}-cloud.agilepromoter.com
    secretName: agilepromoter-cert
  rules:
  - host: "${ENVIRONMENT_NAME}-cloud.agilepromoter.com"
    http:
      paths:
      - path: /${REDIRECT}
        backend:
          serviceName: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
          servicePort: 8080
EOT
}

function check_deployment_exists_in_kubernetes() {
  recover_deploys=`kubectl --namespace=${ENVIRONMENT_NAME} get deployments ${ENVIRONMENT_NAME}-${APPLICATION_NAME}`
  deploy_name=`echo $recover_deploys | cut -d " " -f7`

  if [[ $deploy_name == ${ENVIRONMENT_NAME}-${APPLICATION_NAME} ]];
     then
        echo "true"
     else
        echo "false"
  fi
}

function kubernete_deploy() {
    file_exists=$( check_deployment_exists_in_kubernetes )

    if [[ $file_exists == 'true' ]];
       then
          if [[ $FORCE == 'true' ]];
              then
                kubectl --namespace=${ENVIRONMENT_NAME} delete -f ./kubernetes/deployments/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
                kubectl --namespace=${ENVIRONMENT_NAME} create -f ./kubernetes/deployments/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
              else
                kubectl --namespace=${ENVIRONMENT_NAME} set image deployment/${ENVIRONMENT_NAME}-${APPLICATION_NAME} ${ENVIRONMENT_NAME}-${APPLICATION_NAME}=$IMAGE
          fi
       else
          kubectl --namespace=${ENVIRONMENT_NAME} create -f ./kubernetes/deployments/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
    fi
}

function create_file_deploy() {
  if [[ $EXTERNAL == 'true' ]];
     then
        create_file_deploy_external
     else
        create_file_deploy_internal
  fi
  update_repository
}

function update_repository() {
  mv ${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml ./kubernetes/deployments/${ENVIRONMENT_NAME}/${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml
  git checkout master
  git pull origin master
  git add .
  git commit -m "Gerado o deployment do microserviço ${APPLICATION_NAME}"
  git push -u origin master
}

function start_deploy_process() {
  check_parameters
  file_exists=$( check_deployment_exists_in_repository )

  if [[ $file_exists == 'false' ]];
     then
      create_file_deploy
  fi
  kubernete_deploy
}


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

if [[-z "$REPLICAS"]]; then
  REPLICAS=1
fi

if [[-z "$FORCE"]]; then
  FORCE="false"
fi


#
#  Starts the deploy process
#
start_deploy_process
