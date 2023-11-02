resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.eks_cluster_name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  tags                      = var.tags
  version                   = var.eks_cluster_version
  enabled_cluster_log_types = var.cluster_log_types

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster_securitygroup.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
    ip_family         = "ipv4"

  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_alias.eks_kms_alias.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.cloudwatch_log_group.0,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]
}