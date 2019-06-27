# Platform
This creates a platform in kubernetes to build, test and deploy an application.

## Design goals
* Jenkins Configuration as code using the jcasc plugin
* Reproducible platform
* Dynamic slaves for jenkins
* Visibility & Observability
* Decoupled service deployment (in kubernetes) 

## Prerequisites
* docker (1.18.*)
* docker-compose (1.23.*)
* minikube
* kubectl (1.15.*)
* helm (v2.14.*)

## Components
* Jenkins
* Prometheus
* Grafana

## Steps

### setup minikube and helm

Start a minikube instance

$ `minikube start --memory 4096`

Enable ingress addon

$ `minikube addons enable ingress`

Install tiller (make sure `minikube` is the current context by `kubectl config current-context`)

$ `helm init` (installs tiller in `kube-system`)

### install prometheus and grafana

Please note `values.yaml` has been customized

$ `cd kubernetes/monitoring`

$ `./install_crd.sh` (required because of this: https://github.com/helm/charts/tree/master/stable/prometheus-operator#helm-fails-to-create-crds)

$ `./install`


### install jenkins

Please note `values.yaml` has been customized

$ `cd kubernetes/jenkins`

creates a persistence volume & claim before for jenkins helm chart deployment
$ `kubectl apply -f manifests/pv.yaml` 
$ `kubectl apply -f manifests/pvc.yaml`

$ `./install`

it may take couple of minutes for jenkins to be up and running 

### make host file entries

```$xslt
{minikube ip}  prometheus.amit.local
{minikube ip}  grafana.amit.local
{minikube ip}  jenkins.amit.local
```

### Urls
* prometheus: http://prometheus.amit.local
* grafana: http://grafana.amit.local
* jenkins: http://jenkins.amit.local

### Default passwords

* grafana - (admin:admin)
* jenkins - (admin:`printf $(kubectl get secret --namespace jenkins jenkins-r1 -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo`)

#### Manual steps for jenkins
* Upload an ssh private key for github in jenkins under the jenkins credential id `github_ssh` to get access to the private repos
* Get your current kubeconfig for minikube by running `kubectl config view --flatten --minify`, you'll need only the minikube context.
* With the flattened kubeconfig obtained in the previous step replace the existing kubeconfig content of `k8s-admin` by going here: http://jenkins.amit.local/credentials/store/system/domain/_/credential/k8s-admin/update
* You may have to manually trigger the multibranch job by clicking `Scan Multibranch Pipeline Now` button


## Limitations
* No TLS
* No RBAC in kubernetes or Jenkins
* Job definition is moved to [this public repositry](https://github.com/amit242/jobdsl/blob/master/app.dsl), for JCASC to access and build. This could have been avoided by creating a seed job
* Could not implement docker image publish as uploading images to docker hub was taking a lot of time. Tried a private registry (`registry/docker-compose.yaml`) but disabling tls verification for the private registry was not trivial in minikube. This Limitation can easily be fixed by having a local registry.

## Improvements 
* Linting and static code analysis
* Versioning (app and dependencies)
* Secrets management
* Security
* Scalability
* Operations using gitops


