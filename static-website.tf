# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = "${var.website_bucket_name}"
  acl = "public-read"
  region = "${var.region}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
# AWS S3 bucket for www-redirect
resource "aws_s3_bucket" "website_redirect" {
  bucket = "www.${var.website_bucket_name}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.website_bucket_name}"
  }
}
#data for bucket policy, restricted to IP address
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    sid = "PublicReadForGetBucketObjects"
    resources = [
      "arn:aws:s3:::${var.website_bucket_name}/*",
    ]
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    condition {
     test     = "IpAddress"
     variable = "aws:SourceIp"
     values = [
   	  "${var.ip_address}"
     ]
   }
  }
}
#Push folder to S3
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/s3Contents s3://${aws_s3_bucket.website.id}"
  }
  depends_on = ["aws_s3_bucket.website"]
}