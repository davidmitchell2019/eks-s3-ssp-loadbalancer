#output the bucket url
output "url" {
  value = "${aws_s3_bucket.website.bucket}.s3-website-${var.region}.amazonaws.com"
}
output "loadBalancerAddress4" {
  value = "${kubernetes_service.nginx.load_balancer_ingress}"
}

##################################################################################################################################################
#TODO: write load balancer address to the s3Contents folder and into the file where the endpoint address for the front end to meet the back end is
##################################################################################################################################################