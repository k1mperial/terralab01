output "vpc_id" {
  value = aws_vpc.terraformvpc.id
}

output "public_subnet_id" {
  value = aws_subnet.publicsubnet.id
}

output "private_subnet_id" {

  value = [aws_subnet.privatesubnet[0].id, aws_subnet.privatesubnet[1].id]
}


