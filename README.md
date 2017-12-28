# Build a Continuous Deployment Pipeline with Jenkins and Kubernetes

## Introduction
This guide will take you through the steps necessary to continuously deliver your software to end users. If you are not familiar with basic Kubernetes concepts, have a look at [Kubernetes 101](https://kubernetes.io/docs/user-guide/walkthrough).
In order to accomplish this goal you will use the following Jenkins plugins:
  - [GitHub Pull Request Builder](https://wiki.jenkins.io/display/JENKINS/GitHub+pull+request+builder+plugin) - 
  - [GitHub hook trigger for GITScm polling](https://wiki.jenkins.io/display/JENKINS/GitHub+Plugin) - 
  - [Jenkins Pipelines](https://jenkins.io/solutions/pipeline/) - define our build pipeline declaratively and keep it checked into source code management alongside our application code


In order to deploy the application with [Kubernetes](http://kubernetes.io/) you will use the following resources:
  - [Deployments](http://kubernetes.io/docs/user-guide/deployments/) - replicates our application across our kubernetes nodes and allows us to do a controlled rolling update of our software across the fleet of application instances
  - [Services](http://kubernetes.io/docs/user-guide/services/) - load balancing and service discovery for our internal services
  - [Ingress](http://kubernetes.io/docs/user-guide/ingress/) - external load balancing and SSL termination for our external service
  - [Secrets](http://kubernetes.io/docs/user-guide/secrets/) - secure storage of non public configuration information, SSL certs specifically in our case

## Prerequisites
