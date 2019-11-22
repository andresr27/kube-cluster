# Kuberentes Cluster Example

This is minimal fork of example provided by:

https://github.com/terraform-providers/terraform-provider-aws

Edit terraform.tfvars

> aws_access_key = ""

> aws_secret_key = ""


# Deploy Cluster

> cd examples/examples/eks-getting-started

> sudo terraform apply

> terraform output kubeconfig > ~/.kube/config

> terraform output config_map_aws_auth > config_map.yaml

> kubectl apply -f config_map.yaml

> kubectl get pvc

> kubectl get svc



# Deploy Services

Deploy services in kustomization.yml

> cd services
> kubectl apply -k ./

> kubectl get pods

You need to have aws-authenticator configured.

# Detroy Cluster

> sudo terraform destroy
