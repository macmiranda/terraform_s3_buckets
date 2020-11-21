# Automating S3 bucket creation with for_each loops

## Getting started

When cloning this repository, use the option `--recursive` to initialize and update the submodule.

Configure an IAM user with programatic access only and apply the following policy to that account:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "kms:GetPublicKey",
                "s3:*",
                "kms:GetKeyPolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "kms:ListResourceTags",
                "kms:GetParametersForImport",
                "iam:ListInstanceProfilesForRole",
                "kms:DescribeCustomKeyStores",
                "kms:GetKeyRotationStatus",
                "kms:ScheduleKeyDeletion",
                "kms:DescribeKey",
                "kms:CreateKey"
            ],
            "Resource": "*"
        }
    ]
}
```

<sub>Note: You may want to tune the above policy with stricter permissions.</sub>

This project assumes only EC2 instances will access the created buckets (and creates a IAM role for that purpose, displaying the resulting ARN as part of the output variables).

The access policy can be configured per bucket (see below).

Make sure you properly back up your `terraform.tfstate` or use a different backend to store it. By default, `terraform` will save it to the local directory from where it's being invoked.

## Using the AWS provider

You can configure your AWS global settings in `aws.tf`

Credentials can be provided in this file, via Environment Variables or via a Shared Credentials File. For more information see the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)

## Getting Started

Configuration in this directory creates as many S3 buckets as declared in the `terraform.tfvars`. Each bucket can have its own configuration for the items listed below:

- bucket access policy
- versioning
- lifecycle rules
- server-side encryption
- object locking

The upstream `terraform-aws-s3-bucket` module allows for extra configuration parameters that are outside of the scope of this project but could be incorporated later such as:

- static web-site hosting
- CORS

If you add these to your project, please create a pull request.

## Usage

Create a `terraform.tfvars` file with the following structure:

```tf
buckets = {
  bucket1 = { ... },
  bucket2 = { ... },
  ...
  bucketN = { ... },
}
```

For each bucket you can define the following variables:

```tf
    bucket        = "my-bucket-name",
    bucket_policy_actions = [ "s3:*", ],
    acl           = "private",
    force_destroy = true,
    attach_policy = true,
    tags          = {
        project = "my_project_name",
        name = "my_bucket_name",
    },
    versioning = {
        enabled = true
    },
    lifecycle_rule = [
        {
        id      = "root"
        enabled = true
        prefix  = "/"

        tags = {
            rule      = "root"
            autoclean = "true"
        }

        transition = [
            {
            days          = 30
            storage_class = "ONEZONE_IA"
            }, {
            days          = 60
            storage_class = "GLACIER"
            }
        ]

        expiration = {
            days = 90
        }

        noncurrent_version_expiration = {
            days = 30
        }
        },
    ],

    object_lock_configuration = {
        object_lock_enabled = "Enabled"
        rule = {
        default_retention = {
            mode  = "COMPLIANCE"
            years = 5
        }
        }
    },
    # S3 bucket-level Public Access Block configuration
    block_public_acls       = true,
    block_public_policy     = true,
    ignore_public_acls      = true,
    restrict_public_buckets = true,
```
See an example [here](https://github.com/macmiranda/friday_s3_buckets/blob/main/examples/terraform.tfvars.example).

For more details, visit the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

To create the specified resources you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources anymore.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.2, < 0.14 |
| aws | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0, < 4.0 |

## Outputs

| Name | Description |
|------|-------------|
| this\_aws\_iam\_role\_arn | The ARN of the role that will have access to the buckets. Will be of format `arn:aws:iam::account-id:role/rolename`. |
| this\_s3\_bucket\_arn | The ARN of the bucket. Will be of format `arn:aws:s3:::bucketname`. |
| this\_s3\_bucket\_bucket\_domain\_name | The bucket domain name. Will be of format `bucketname.s3.amazonaws.com`. |
| this\_s3\_bucket\_bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name. |
| this\_s3\_bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| this\_s3\_bucket\_id | The name of the bucket. |
