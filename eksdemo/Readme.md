CONSOLE




# Set up Access to the cluster for tiller

> kubectl apply -f rbac.yaml
> helm init --service-account tiller

Note: Tiller needs to be secure 

> run `helm init` with the --tiller-tls-verify flag.

https://docs.helm.sh/using_helm/#securing-your-helm-installation

> helm completion bash >> ~/.bash_completion
> . /etc/profile.d/bash_completion.sh
> . ~/.bash_completion


# Using HELM to deploy images

> helm search nginx

> helm install --name mywebserver bitnami/nginx

> kubectl describe deployment mywebserver

Clean up

> helm list 

> helm delete --purge mywebserver




# DEPLOY MICROSERVICES WITH HELM


> helm create Demo
 
> helm install --debug --dry-run --name workshop . 

> kubectl get pods

> helm status workshop

Cool way to get the service url from svc command

> kubectl get svc ecsdemo-frontend -o jsonpath="{.status.loadBalancer.ingress[*].hostname}"; echo

Go to the explorer to see if it works, it can take a few minutes.

Introduce failure, for example change the name of the image in values.yaml

> helm upgrade workshop .

> helm history workshop

> helm rollback workshop 1hel

> helm status workshop

Clean up and remember to fix the error introduced in your file.

> helm delete workshop


# Custom Health Checks

Liveness:

> kubectl apply -f liveness-app.yaml

> kubectl describe pod liveness-app

> kubectl exec -it liveness-app -- /bin/kill -s SIGUSR1 1

> kubectl describe pod liveness-app


Readiness:

>kubectl apply -f readiness-deployment.yaml

> kubectl describe deployment readiness-deployment | grep Replicas:

Introduce failure

> kubectl exec -it <YOUR-READINESS-POD-NAME> -- rm /tmp/healthy

> kubectl get pods -l app=readiness-deployment

Fix 

> kubectl exec -it <YOUR-READINESS-POD-NAME> -- touch /tmp/healthy







# HPA

Deploy the Metrics Server

Method 1: Works but gives unknown for the target CPU when getting hpa

Reference. eksworkshop.com

helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.4 \
    --namespace metrics

In a few minutes you should be able to list metrics using the following:

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"

Verify deployment is running 

kubectl get deployment metrics-server -n kube-system


helm del --purge metrics-server


>>>> Method 2 

Reference
https://aws.amazon.com/es/premiumsupport/knowledge-center/eks-metrics-server-pod-autoscaler/



git clone https://github.com/kubernetes-incubator/metrics-server.git
cd metrics-server/

kubectl create -f deploy/1.8+/



# edit metric-server deployment to add the flags

kubectl edit deploy -n kube-system metrics-server

spec:
  containers:
  - args:
    - --kubelet-insecure-tls
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    image: k8s.gcr.io/metrics-server-amd64:v0.3.6


Deploy metric-server 


> kubectl apply -f metrics-server-0.3.6/deploy/1.8+/


Verify deployment is running 

> kubectl get deployment metrics-server -n kube-system



Confirm the Metrics API is available

> kubectl get apiservice v1beta1.metrics.k8s.io -o yaml

> kubectl get pods -n kube-system

> kubectl get pods -n kube-system | grep metrics-server

> kubectl logs -n kube-system --since=1h metrics-server-596d74f577-4sfsh

 unable to fully collect metrics: unable to fully scrape metrics from source kubelet_summary





Deploy a Sample App 

> kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80


> kubectl delete deployment php-apache

Or specific parts

> kubectl delete svc php-apache
> kubectl delete pod php-apache





Create a HPA resource
	
> kubectl get hpa 

!!!! This command returns unknown on target metric -> see method 2 to deploy metrics

> kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

Create new container to test:

> kubectl run -i --tty load-generator --image=busybox /bin/sh

Te reattach

kubectl attach load-generator-7fbcc7489f-nckbd -c load-generator -i -t

Run the following loop on the container shell

> while true; do wget -q -O - http://php-apache; done





