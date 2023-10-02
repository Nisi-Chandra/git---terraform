variable "vpc_cidr_block" {
  description = "Name of project name"
  default     = "172.16.0.0/16"
}


variable "image1" {
  description = "image type"
  type        = string
  default     = "blue"
}

variable "image2" {
  description = "image type"
  type        = string
  default     = "green"
}




variable "region" {
  default = "ap-south-1"
}

variable "access_key" {
  default = "MKAKIA3ZWQXAGE5BI3HWT5"
}

variable "secret_key" {
  default = "nGchE78Xuej/1+zRmvyb0oA1VlZXk78lnGmWJQKkmk"
}

variable "private_zone_name" {
  default = "nisichandra.local"
}

variable "public_zone_name" {
  default = "nisichandra.in"
}
variable "project_name" {
  description = "project_name"
  default     = "ALB"
}

variable "project_environment" {
  description = "Name of project environment"
  default     = "dev"
}

variable "ami-id" {
  description = "Project-ami"
  type        = string
  default     = "ami-057752b3f1d6c4d6c"
}


variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "availability_zone" {
  default = "ap-south-1"
}


