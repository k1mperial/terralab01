# Create a VPC
resource "aws_vpc" "terraformvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "terraformvpc"
  }
}


#Create the Internet Gateway
resource "aws_internet_gateway" "terraformigw" {
  vpc_id = aws_vpc.terraformvpc.id

  tags = {
    Name = "terraformigw"
  }
}
#Create the NAT GW EIP
resource "aws_eip" "natgweip" {
  vpc      = true
}

#Create the Nat Gateway
resource "aws_nat_gateway" "terraformnatgw" {
  allocation_id = aws_eip.natgweip.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name = "NATgw"
  }
}

#Create Public subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = var.public_cidr

  tags = {
    Name = "publicsubnet"
  }
}

#Create Private subnet
resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = var.private_cidr
  availability_zone = var.RDSregion
  tags = {
    Name = "privatesubnet"
  }
}

# #Create another Private subnet for the RDS instance

# resource "aws_subnet" "privaterdssubnet" {
#   vpc_id     = aws_vpc.terraformvpc.id
#   cidr_block = var.private_cidr
#   availability_zone = var.RDSregion

#   tags = {
#     Name = "privaterdssubnet"
#   }
# }


#Create Public Route Table

resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.terraformvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraformigw.id
  }


  tags = {
    Name = "PublicRT"
  }
}

#Associate Public Route to Public Subnet

resource "aws_route_table_association" "pubRT" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicroute.id
}

#Create Private Route Table

resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.terraformvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraformnatgw.id
  }


  tags = {
    Name = "PrivateRT"
  }
}

#Associate Private Route to Private Subnet
resource "aws_route_table_association" "priRT" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privateroute.id
}
