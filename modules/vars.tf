variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "RDSregion" {
  type    = string
  default = "eu-west-2b"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "public_cidr" {
  default = "10.0.0.0/16"
}


variable "private_cidr" {
  default = "10.0.0.0/16"
}


