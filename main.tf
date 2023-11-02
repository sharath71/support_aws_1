module "tf_vpc" {
  source = "./vpc"
  vpc_tags = {
   Name = "Tag VPC"
   Location = "HYD"  
             }
} 
module "eks_cluster_1" {
  source                               = "./eks"
  location                             = "eu-north-1"                                            ## Mandatory
  eks_cluster_name                     = "JHC-Assignment"                                          ## Mandatory
  count                                = "3"
  subnet_ids                           = module.tf_vpc.pub_sub_ids ## Mandatory
  cluster_log_types                    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  eks_cluster_version                  = 1.25            ## Optional
  cluster_endpoint_private_access      = true            ## Optional 
  cluster_endpoint_public_access       = true            ## Optional
  cluster_endpoint_public_access_cidrs = null            ## Optional 
  service_ipv4_cidr                   = module.tf_vpc.vpc_id ## Optional 
  log_retention_in_days                = 7               ## Optional
  ##Node Group
  node_desired_size    = 2             ## Optional 
  node_max_size        = 10             ## Optional 
  node_min_size        = 2             ## Optional  
  node_instance_types  = ["t3.small"] ## Optional   
  node_disk_size       = 50            ## Optional  
  node_ami_type        = "AL2_x86_64"  ## Optional   
  node_max_unavailable = 1             ## Optional  
  node_capacity_type   = "ON_DEMAND"   ## Optional   
  tags = {                             ## Optional
    "CreatedBy" = "JHC"         ## Optional
    "Env"         = "prd"              ## Optional
    "clusterName" = "JHC-prd"
  }
  enable_oidc_openid_connect   = true
  enable_addon_coredns         = true
  coredns_addon_version        = null
  enable_addon_kube_proxy      = true
  kube_proxy_addon_version     = null
  enable_addon_ebs_csi_driver  = true
  ebs_csi_driver_addon_version = null
  enable_addon_vpc_cni         = true
  vpc_cni_addon_version        = null

  create_cluster_autoscaler = true
  create_metrics_server     = true
}

module "s3bucket" {
  source = "./s3"
}

module "jhc_rds" {
  source  = "./rds"
  sub_ids = module.tf_vpc.pri_sub_ids
  vpc_id  = module.tf_vpc.vpc_id
  rds_ingress_rules = {
    "app1" = {
      port            = 5432
      protocol        = "tcp"
      cidr_blocks     = []
      description     = "allow ssh within organization"
      security_groups = [module.eks_cluster_1[0].security_group_id]
    }
  }
}