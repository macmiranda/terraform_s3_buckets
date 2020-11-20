data "aws_canonical_user_id" "current" {}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "bucket_policy" {
  for_each = var.buckets
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = each.value.bucket_policy_actions

    resources = [
      "arn:aws:s3:::${each.value.bucket}",
    ]
  }
}

module "s3_bucket" {
  source        = "./terraform-aws-s3-bucket"
  for_each      = var.buckets
  bucket        = each.value.bucket
  acl           = each.value.acl
  force_destroy = each.value.force_destroy
  attach_policy = each.value.attach_policy
  tags          = each.value.tags
  versioning    = each.value.versioning
  lifecycle_rule = each.value.lifecycle_rule
  object_lock_configuration = each.value.object_lock_configuration
  policy        = data.aws_iam_policy_document.bucket_policy[each.key].json
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}
