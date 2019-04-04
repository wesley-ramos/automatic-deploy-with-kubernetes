# Build a Continuous Deployment Pipeline with Jenkins and Kubernetes


## Introduction

Script developed with the purpose of facilitating the deploy of a new microservice.

## Prerequisites
 - Jenkins
 - Kubernetes 
 
## how to use?

1. Public services:

```shell

./start.sh --environment=staging --namespace=staging --name=my-service --image=image-of-my-service --replicas=1 --force=false --host=my-host --secret=deploy-secret --registry=repo-image --expose=service-path --configuration-directory=./

```

2. Private services:

```shell

./start.sh --environment=staging --namespace=staging --name=my-service --image=image-of-my-service --replicas=1  --force=false --host=my-host --secret=deploy-secret --registry=repo-image

```
