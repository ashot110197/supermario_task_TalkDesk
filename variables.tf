variable "region" {
  default = "us-east-1"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}
variable "cidr_subnets" {
 	type = list
  description = "CIDR block for the subnet"
	default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "availability_zones" {
  description = "availability zones to create subnets"
 	type = list
  default     =   ["us-east-1a", "us-east-1b"]
}
variable "public_key_path" {
  description = "Public key path"
  default     = "~/.ssh/id_rsa.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default     = "ami-0747bdcabd34c712a"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default     = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default     = "Production"
}