#kubernetes provider
provider "kubernetes" {
  host                   = "${aws_eks_cluster.ssp-cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.ssp-cluster.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.cluster_auth.token}"
  load_config_file       = false
}
#aws provider
provider "aws"
{
  region = "${var.region}"
}