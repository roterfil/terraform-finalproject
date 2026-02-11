output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets" {
  value = [
    aws_subnet.pub_1.id,
    aws_subnet.pub_2.id
  ]
}

output "private_subnets" {
  value = [
    aws_subnet.priv_1.id,
    aws_subnet.priv_2.id
  ]
}