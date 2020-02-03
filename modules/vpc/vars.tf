variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "public_cidr" {
  default = "10.0.1.0/24"
}


variable "private_cidr" {
  default = "10.0.2.0/24"
}
  


