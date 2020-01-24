
#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#


resource "aws_iam_openid_connect_provider" "demo" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = "${aws_eks_cluster.demo.identity.0.oidc.0.issuer}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "demo_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.demo.arn}"]
      type        = "Federated"
    }
  }
}

#################     IAM ROLES      #####################

# Change the assume_role command to  assume_role_policy = "${data.aws_iam_policy_document.example_assume_role_policy.json}"

resource "aws_iam_role" "demo" {
  name = "role-cluster-demo"
  description = "Allows user to create cluster and services with EKS?"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

resource "aws_iam_role_policy_attachment" "cluster-demo-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.demo.name
}

# resource "aws_iam_role" "ksa" {
#   name = "role-cluster-sa"
#   description = "Role to allow K8s service account access to AWS resources"
#
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }



# resource "aws_iam_role_policy_attachment" "cluster-demo-AmazonS3ReadOnlyAccess" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
#   role       = aws_iam_role.ksa.name
# }

########## SECURITY GROUPS ########

resource "aws_security_group" "cluster-demo" {
  name        = "eks-cluster-demo"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-demo"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster-demo.id
  source_security_group_id = aws_security_group.cluster-demo.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster-demo.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.demo.arn

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster-demo.id}"]
    subnet_ids         = aws_subnet.demo[*].id
  }

 # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
 # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.

  depends_on = [
    aws_iam_role_policy_attachment.cluster-demo-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-demo-AmazonEKSServicePolicy,
  ]
}
