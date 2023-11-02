resource "aws_vpc" "vpc1"{
	cidr_block = var.vpc_cidr
	instance_tenancy = "default"
	tags = var.vpc_tags
	
}

############# Public_Subnets   #########
resource "aws_subnet" "subnets1" { 
   count = var.subnet_count
   vpc_id = aws_vpc.vpc1.id
   availability_zone = local.az_names[count.index]
   cidr_block = var.pub_cidrs[count.index]
}

############# Private_Subnets   #########
resource "aws_subnet" "subnets2" {
   count = var.subnet_count
   vpc_id = aws_vpc.vpc1.id
   availability_zone = local.az_names[count.index]
   cidr_block = var.pri_cidrs[count.index]
}
