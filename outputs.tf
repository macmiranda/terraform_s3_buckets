output "this_aws_iam_role_arn" {
  description = "The ARN of the role that will have access to the buckets."
  value = aws_iam_role.this.arn
}

output "this_s3_bucket_id" {
  description = "The name of the bucket."
  value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_id }
}

output "this_s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_arn }
}

output "this_s3_bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_bucket_domain_name }
}

output "this_s3_bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_bucket_regional_domain_name }
}

output "this_s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_hosted_zone_id }
}

# Region is currently the same for all buckets
# output "this_s3_bucket_region" {
#   description = "The AWS region this bucket resides in."
#   value       = { for p in sort(keys(var.buckets)) : p => module.s3_bucket[p].this_s3_bucket_region }
# }

