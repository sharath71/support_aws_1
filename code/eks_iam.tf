resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.eks_cluster_name}-eks-nodegroup-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}



resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}


resource "aws_iam_policy" "eks-cluster-autoscaler-policy" {
  name        = "${var.eks_cluster_name}-eks-cluster-autoscaler-policy"
  description = "${var.eks_cluster_name}-eks-cluster-autoscaler-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },

      {
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.eks_cluster_name}" : "owned"
          }
        }
        "Effect" : "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-autoscaler-policy" {
  policy_arn = aws_iam_policy.eks-cluster-autoscaler-policy.arn
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AutoScalingFullAccess-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_nodegroup_role.name
}

data "tls_certificate" "eks_tls_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_iam_openid_connect_provider" {
  count           = var.enable_oidc_openid_connect == true ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  tags = merge(
    var.tags,
    {
      associated_cluster = "${var.eks_cluster_name}"
    }
  )
}

data "aws_iam_policy_document" "eks-cluster-openid_connect" {
  count = var.enable_oidc_openid_connect == true ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_iam_openid_connect_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_iam_openid_connect_provider[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks-cluster-openid_connect" {
  count              = var.enable_oidc_openid_connect == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.eks-cluster-openid_connect[0].json
  name               = "${var.eks_cluster_name}-eks-cluster-openid_connect"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  count = var.enable_addon_vpc_cni == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-cluster-openid_connect[0].name
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver_Policy" {
    count = var.enable_addon_ebs_csi_driver == true ? 1 : 0
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-cluster-openid_connect[0].name
}
