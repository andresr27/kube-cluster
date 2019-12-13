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

> kubectl get svc



You need to have aws-authenticator configured.

# Destroy Cluster

> sudo terraform destroy

# Access Console

>kubectl proxy

Get a token to connecto your cluster

> aws eks get-token --cluster-name terraform-eks-demo | jq -r '.status.token'

Go to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ and insert the token.

# Deploy Services

Deploy services in kustomization.yml

> cd services

Create a file named password in this directory with no end of line to use in secret generation.

save your mysqlRootPassword in a files called password with no extension, end of line or forbidden symbols

> kubectl apply -k ./

Check that physical volume claims have bounded

> kubectl get pvc

Check that pods are running without errors

> kubectl get pods

See info about running services

> kubectl get scv
