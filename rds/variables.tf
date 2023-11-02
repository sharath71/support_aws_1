variable "sub_ids" {
}

variable "storage" {
  default = 20
}
variable "rds_version" {
  default = "14"
}
variable "inst_class" {
  default = "db.m5d.xlarge"
}
variable "engine_name" {
  default="postgres"
  
}
variable "db_name" {
  default = "jhcdb"
}
variable "username" {
  default = "jhc"
}
variable "password" {
  default = "jhc123"
}
variable "vpc_id" {
}
variable "rds_ingress_rules" {
  type = map(object({
    port            = number
    protocol        = string
    cidr_blocks     = list(string)
    description     = string
    security_groups = list(string)
  }))
}
