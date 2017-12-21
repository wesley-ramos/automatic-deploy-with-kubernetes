#!/bin/bash

# Wesley Ramos <wesley-ramos-de-paula@hotmail.com>
#
# Info: Script responsible for creating the deploy file.
# ==================================================================================================
#

function create_deployment_file_for_internal_service() {
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


function create_deployment_file_for_external_service() {
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
      - path: /${PATH}
        backend:
          serviceName: ${ENVIRONMENT_NAME}-${APPLICATION_NAME}
          servicePort: 8080
EOT
}

function check_configuration_file_exists() {
  if [ -e "./${ENVIRONMENT_NAME}-${APPLICATION_NAME}.yml" ]
    then
      echo "true"
    else
      echo "false"
  fi
}

function generate_configuration_file() {
  if [[ -z "$PATH" ]]
    then
      create_deployment_file_for_internal_service
    else
      create_deployment_file_for_external_service
  fi
}
