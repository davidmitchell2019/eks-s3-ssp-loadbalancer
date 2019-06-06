#create the cluster
resource "aws_eks_cluster" "ssp-cluster" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.cluster-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster-security-group.id}"]
    subnet_ids         = ["${aws_subnet.ssp-subnets.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy",
  ]
}

