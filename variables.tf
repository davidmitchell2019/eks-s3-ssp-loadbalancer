#name of the cluster
variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}
#the website bucket name
variable "website_bucket_name" {
  type = "string"
  default = "ssp-test-bucket-for-uploading-to-json"
}
#region name
variable "region" {
  type = "string"
  default = "eu-west-2"
}
#doctored for testing
variable "ip_address"
{
  type = "string"
  default = "0.0.0.0/0"
}
#add the arn role for the account that terraform will use to keep authentication with eks
variable "arn_role"
{
  type = "string"
  default = "arn:aws:iam::870539827412:root"
}
