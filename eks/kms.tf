data "aws_caller_identity" "caller_identity" {}

locals {
  account_id = data.aws_caller_identity.caller_identity.account_id
}


resource "aws_kms_key" "eks_kms_key" {
  description             = "KMS Key for Cluster - ${var.eks_cluster_name}"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.iam_policy.json
  enable_key_rotation     = true
  is_enabled              = true
  tags = merge(
    var.tags,
    {
      cloudwatch_log_group_name = "${var.eks_cluster_name}-eks-cluster-cloudwatch"
      associated_cluster        = "${var.eks_cluster_name}"
    }
  )
}

data "aws_iam_policy_document" "iam_policy" {
  statement {
    actions   = ["kms:*"]
    effect    = "Allow"
    sid       = "Allow root user to manage the KMS key and enable IAM policies to allow access to the key."
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    effect    = "Allow"
    resources = ["*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_kms_alias" "eks_kms_alias" {
  name          = "alias/eks-cluster-${var.eks_cluster_name}"
  target_key_id = join("", aws_kms_key.eks_kms_key.*.arn)
}

