locals {
   az_names = data.aws_availability_zones.azs.names
   pub_sub_ids = aws_subnet.subnets1.*.id
   pri_sub_ids = aws_subnet.subnets2.*.id
}