# kube-cluster

Edit terraform.tfvars

> aws_access_key = ""
> aws_secret_key = ""


# Deploy Cluster

> sudo terraform apply
> terraform output kubeconfig > ~/.kube/eksconfig
> kubectl get svc
> sudo terraform destroy

# Deploy Services

Deploy services in kustomization.yml

> kubectl apply -k ./
> kubectl get pods

You need to have aws-authenticator configured.
