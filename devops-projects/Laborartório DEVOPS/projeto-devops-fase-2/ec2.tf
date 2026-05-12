resource "aws_instance" "website_server" {
  ami                    = "ami-0b016c703b95ecbe4" #Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  key_name               = "chave-site-prod"
  vpc_security_group_ids = [aws_security_group.website_sg.id]
  iam_instance_profile   = "ECR-EC2-Role"

  tags = {
    Name        = "website-server"
    Provisioned = "Terraform"
    Cliente     = "Maria"
  }
}

## Security Group
resource "aws_security_group" "website_sg" {
  name   = "website-sg"
  vpc_id = "vpc-0ff60a695425883cf"
  tags = {
    Name        = "website-sg"
    Provisioned = "Terraform"
    Cliente     = "Maria"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.website_sg.id
  cidr_ipv4         = "seu-ip/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.website_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.website_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.website_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

