#Cluster iam role policy
resource "aws_iam_role" "cluster-iam-role" {
  name = "eks-cluster-iam-role"

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
#Amazon EKS cluster policy attachment
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster-iam-role.name}"
}
#Amazon EKS service policy attachment
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster-iam-role.name}"
}
resource "aws_iam_role" "node-iam-role" {
  name = "eks-node-assume-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
#EKS worker node policy attachement
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node-iam-role.name}"
}

#CNI policy attachment
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node-iam-role.name}"
}

#create an arn role for container registry authentication
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node-iam-role.name}"
}
#node instance profile
resource "aws_iam_instance_profile" "node-instance-profile" {
  name = "terraform-eks-instance-profile"
  role = "${aws_iam_role.node-iam-role.name}"
}

#Kubectl assume role policy document for authentication to cluster replacing heptio authentication
data "aws_iam_policy_document" "kubectl_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

principals {
      type        = "AWS"
      identifiers = ["${var.arn_role}"]
    }
  }
}
#kubectl assume role policy
resource "aws_iam_role" "eks_kubectl_role" {
  name               = "eks-kubectl-access-role"
  assume_role_policy = "${data.aws_iam_policy_document.kubectl_assume_role_policy.json}"
}
#cluster policy attachment
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
#policy attachment for kubectl server
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
#Worker node policy attachment
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_kubectl_role.name}"
}
#############cluster auth
data "aws_eks_cluster_auth" "cluster_auth" {
  name = "${var.cluster-name}"
}
##############################################################
#output the arn of the node role
output "aws_iam_node_role_arn_output" {
  value = "${aws_iam_role.node-iam-role.arn}"
}
#output the arn of the node role
output "aws_eks_kubectl_role_arn_output" {
  value = "${aws_iam_role.eks_kubectl_role.arn}"
}