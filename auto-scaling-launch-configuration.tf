data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.ssp-cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.ssp-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.ssp-cluster.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}
resource "aws_launch_configuration" "launch-config" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.node-instance-profile.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.micro"
  name_prefix                 = "terraform-eks"
  security_groups             = ["${aws_security_group.node-security-group.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }

}
resource "aws_autoscaling_group" "eks-auto-scaling-group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.launch-config.id}"
  max_size             = 3
  min_size             = 2
  name                 = "terraform-eks"
  vpc_zone_identifier  = ["${aws_subnet.ssp-subnets.*.id}"]

  tag {
    key = "kubernetes.io/cluster/${var.cluster-name}-${terraform.workspace}"
    value               = "owned"
    propagate_at_launch = true
  }
}
