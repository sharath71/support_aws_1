output "vpc_id" {
  value = aws_vpc.vpc1.id
}
output "pub_sub_ids"{
    value=local.pub_sub_ids

}
output "pri_sub_ids"{
    value=local.pri_sub_ids

}