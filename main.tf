# Configure the AWS Provider
provider "aws" {
  region = var.region
}

#Import the VPC module
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = "192.168.0.0/16"
  public_cidr  = "192.168.1.0/24"
  private_cidr = ["192.168.2.0/24", "192.168.3.0/24"]
}

#Create EC2 instances as nginx web servers in the PUblic subnet
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnet_id
  user_data                   = file("files/bootstrap.sh")
  private_ip                  = element(var.public_instance_ips, count.index)
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.publicSG.id,
  ]

  tags = {
    Name = "web-${format("%03d", count.index + 1)}"
  }

  count = length(var.public_instance_ips)
}

#Create an EC2 instance in the first private subnet
resource "aws_instance" "privateVM" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = element(module.vpc.private_subnet_id, 0)
  private_ip                  = element(var.private_instance_ips, count.index)
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.privateSG1.id,
  ]

  tags = {
    Name = "privateVM-${format("%02d", count.index + 1)}"
  }

  count = length(var.private_instance_ips)
}

#Create a DB Subnet Group 
resource "aws_db_subnet_group" "privatedb" {
  name       = "privatedb"
  subnet_ids = [module.vpc.private_subnet_id[0], module.vpc.private_subnet_id[1]]
  
  tags = {
    Name = "My Private DB subnet group"
  }
}


#Create an RDS DB in the private subnet
resource "aws_db_instance" "privateRDS" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  port                 = "3306"
  multi_az             = false
  final_snapshot_identifier = "fooDB2"
  db_subnet_group_name = aws_db_subnet_group.privatedb.id
  vpc_security_group_ids = [
    aws_security_group.privateSG2.id
  ]
}


#Create an ELB for the web servers
resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = [module.vpc.public_subnet_id]
  security_groups = [aws_security_group.publicSG.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = aws_instance.web[*].id
}


# Create security group for the EC2 instances in the public subnet
resource "aws_security_group" "publicSG" {
  name        = "publicSG"
  description = "Allow SSH & HTTP access from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create security group for the EC2 instance in the first private subnet
resource "aws_security_group" "privateSG1" {
  name        = "privateSG"
  description = "Allow SSH access internally"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.publicSG.id]
  }

}

# Create security group for the RDS DB private subnet
resource "aws_security_group" "privateSG2" {
  name        = "privateSG2"
  description = "Allow mySQL access internally"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.publicSG.id]
  }

}



