#! /bin/bash
#kubectl create ns jenkins

helm upgrade --install jenkins-r1 stable/jenkins --version=1.3.2 \
--namespace jenkins \
-f values.yaml