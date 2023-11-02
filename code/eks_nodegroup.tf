resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.eks_cluster_name}-nodegroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.node_ami_type
  capacity_type   = var.node_capacity_type
  disk_size       = var.node_disk_size
  instance_types  = var.node_instance_types


  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  dynamic "remote_access" {
    for_each = var.node_ec2_ssh_key == null ? [] : [1]
    content {
      ec2_ssh_key               = var.node_ec2_ssh_key
      source_security_group_ids = [aws_security_group.eks_cluster_remoteaccess_securitygroup.id]
    }
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

 tags ={
   "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned",
   "k8s.io/cluster-autoscaler/enabled"= "true"

 }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}


