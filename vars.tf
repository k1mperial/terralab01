variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "key_name" {
  type        = string
  description = "The AWS key pair to use for resources."
  default     = "terraformlab"
}

variable "ami" {
  type        = string
  description = "Ubuntu AMI"
  default     = "ami-0be057a22c63962cb"
}

variable "instance_type" {
  type        = string
  description = "The instance type to launch."
  default     = "t2.micro"
}

variable "public_instance_ips" {
  type        = list(string)
  description = "The IPs to use for our public instances"
  default     = ["192.168.1.10", "192.168.1.11"]
}


variable "private_instance_ips" {
  type        = list(string)
  description = "The IPs to use for our private instances"
  default     = ["192.168.2.10"]
}