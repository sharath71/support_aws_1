variable "location" {
  default = null
}

variable "tags" {
  type    = map(any)
  default = null
}
variable "eks_cluster_name" {
  type        = string
  default     = null
  description = "(Required) Name of the cluster. Must be between 1-100 characters in length. Must begin with an alphanumeric character, and must only contain alphanumeric characters"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet id's"
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}
variable "eks_cluster_version" {
  type        = string
  description = "(Optional) Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS"
  default     = null
}
variable "cluster_endpoint_private_access" {
  type        = bool
  description = "(Optional) Whether the Amazon EKS private API server endpoint is enabled. Default is false."
  default     = true
}
variable "cluster_endpoint_public_access" {
  type        = bool
  description = "(Optional) Whether the Amazon EKS public API server endpoint is enabled. Default is true."
  default     = false
}
variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "(Optional) List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0. Terraform will only perform drift detection of its value when present in a configuration."
  default     = null
}

variable "cluster_log_types" {
  type        = list(string)
  description = " (Optional) List of the desired control plane logging to enable"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
variable "log_retention_in_days" {
  type        = number
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire"
  default     = 7
}

variable "service_ipv4_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "must be within 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16"
}


## Node Group

variable "node_ec2_ssh_key" {
  type        = string
  default     = null
  description = "(Optional) EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group. If you specify this configuration, but do not specify source_security_group_ids when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0)."
}
variable "node_source_security_group_ids" {
  type        = list(string)
  default     = null
  description = " (Optional) Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify ec2_ssh_key, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0)"
}

variable "node_desired_size" {
  type        = number
  default     = 1
  description = "(Required) Desired number of worker nodes."
}

variable "node_max_size" {
  type        = number
  default     = 1
  description = "(Required) Maximum number of worker nodes."
}

variable "node_min_size" {
  type        = number
  default     = 1
  description = "(Required) Minimum number of worker nodes"
}

variable "node_max_unavailable" {
  type        = number
  default     = 1
  description = "(Optional) Desired max number of unavailable worker nodes during node group update."
}
variable "node_ami_type" {
  type        = string
  default     = "AL2_x86_64"
  description = " (Optional) Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64"
}

variable "node_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "(Optional) Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT."
}
variable "node_disk_size" {
  type        = number
  default     = 50
  description = "(Optional) Disk size in GiB for worker nodes"
}

variable "node_instance_types" {
  type        = list(string)
  default     = ["t3.small"]
  description = "(Optional) List of instance types associated with the EKS Node Group."
}

variable "map_user" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"
  default     = []
}

variable "map_role" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "enable_oidc_openid_connect" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable OIDC OpenId Connect"
}

## Addons

variable "enable_addon_coredns" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable Add-ons for CoreDNS"
}

variable "coredns_addon_version" {
  type        = string
  default     = null
  description = "(Optional) Specify the Add-ons version or use null for default value to use"
}

variable "enable_addon_kube_proxy" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable Add-ons for kube-proxy "
}

variable "kube_proxy_addon_version" {
  type        = string
  default     = null
  description = "(Optional) Specify the Add-ons version or use null for default value to use"
}

variable "enable_addon_ebs_csi_driver" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable  Add-ons for Amazon EBS CSI Driver"
}

variable "ebs_csi_driver_addon_version" {
  type        = string
  default     = null
  description = "(Optional) Specify the Add-ons version or use null for default value to use"
}

variable "enable_addon_vpc_cni" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable  Add-ons for Amazon VPC CNI"
}

variable "vpc_cni_addon_version" {
  type        = string
  default     = null
  description = "(Optional) Specify the Add-ons version or use null for default value to use"
}


variable "create_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable  helm cluster auto scaler"
}

variable "create_metrics_server" {
  type        = bool
  default     = false
  description = "(Optional) Enable or disable  helm metrics server"
}





 