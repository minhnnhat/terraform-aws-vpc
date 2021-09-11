output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "test" {
  value = { for s in local.subnets : "${s.subnet_name}" => s }
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.subnet : k => v.id }
}

#output "public_sbids" {
#  value = { for k, v in aws_subnet.sub : k => v.id
#  if k == "subnetB1" || k == "subnetB2" }
#}

#output "private_subnet_ids" {
#  value = { for k, v in aws_subnet.subnet : k => v.id
#  if k == "private1a" || k == "private1b" }
#}
