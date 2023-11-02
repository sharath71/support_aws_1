output "eks_cluster" {
    description = "Details of eks cluster"
    value = aws_eks_cluster.eks_cluster
}
output "cluster_name" {
    description = "Name of the eks cluster"
    value = aws_eks_cluster.eks_cluster.name
}


output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.cloudwatch_log_group[0].name, "")
}

output "cloudwatch_log_group_arn" {
  description = "ARN of Cloudwatch log group"
  value       = try(aws_cloudwatch_log_group.cloudwatch_log_group[0].arn, "")
}

output "security_group_id" {
  value = aws_security_group.eks_cluster_securitygroup.id
}
