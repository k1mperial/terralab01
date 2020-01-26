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

#Declare the data source for AZ
data "aws_availability_zones" "available" {
  state = "available"
}

#Create Public subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = var.public_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "publicsubnet"
  }
}

#Create 2 Private subnets
resource "aws_subnet" "privatesubnet" {
  count      = length(var.private_cidr)
  vpc_id     = aws_vpc.terraformvpc.id
  cidr_block = element(var.private_cidr, count.index)
  availability_zone  = data.aws_availability_zones.available.names[count.index]


  tags = {
    Name = "privatesubnet-${format("%02d", count.index + 1)}"
  }
}


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

#Associate Private Route to Private Subnet 01
resource "aws_route_table_association" "priRT1" {
  subnet_id      = aws_subnet.privatesubnet[0].id
  route_table_id = aws_route_table.privateroute.id
}


#Associate Private Route to Private Subnet 02
resource "aws_route_table_association" "priRT2" {
  subnet_id      = aws_subnet.privatesubnet[1].id
  route_table_id = aws_route_table.privateroute.id
}
