terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

#configure the AWS Provider
provider "aws" {
    region = var.region
}

#resources
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.cidr_subnets)
  cidr_block =  element(var.cidr_subnets,count.index)
  map_public_ip_on_launch = "true"
  availability_zone = element(var.availability_zones,count.index)
  tags = {
    "Environment" = var.environment_tag
    "Name" = "Subnet-${count.index+1}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  count = length(var.cidr_subnets)
  subnet_id      = element(aws_subnet.subnet_public.*.id,count.index)
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "supermario_sg" {
  name = "supermario_sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access drom the VPC
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = file(var.public_key_path)
}

resource "aws_lb" "supermario" {
  name               = "supermario-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.supermario_sg.id]
  subnets            = aws_subnet.subnet_public.*.id
  
  tags = {
    "Environment" = var.environment_tag
  }
}

resource "aws_lb_target_group" "supermario" {
  name     = "supermario-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  }

resource "aws_lb_listener" "supermario" {
  load_balancer_arn = aws_lb.supermario.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.supermario.arn
  }
}

resource "aws_lb_target_group_attachment" "supermario" {
  count = length(var.cidr_subnets)
  target_group_arn = aws_lb_target_group.supermario.arn
  target_id        = aws_instance.supermario_instance[count.index].id
  port             = 80
}

resource "aws_instance" "supermario_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  count = length(var.cidr_subnets)
  subnet_id = element(aws_subnet.subnet_public.*.id,count.index)
  vpc_security_group_ids = [aws_security_group.supermario_sg.id]
  key_name = aws_key_pair.ec2key.key_name

  tags = {
		"Environment" = var.environment_tag
	}
}

# Executing ansible playbook
resource "null_resource" "run-ansible-playbook" {
  provisioner "local-exec" {
    command = "ansible-playbook -T 300 main.yml"
  }
  # Run after aws autoscaling group is ready
  depends_on = [aws_instance.supermario_instance]

}
