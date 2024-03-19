data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name                 = "VPC-${var.projectName}"
  cidr                 = "172.31.0.0/16"
  azs                  = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets       = ["172.31.80.0/20", "172.31.16.0/20", "172.31.32.0/20"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/cluster-eks-${var.projectName}}" = "shared"
    "kubernetes.io/role/elb"                                = "1"
  }
  map_public_ip_on_launch = true
}

resource "aws_security_group" "rds-aws-security-group" {
  name        = "rds-production-security-group"
  description = "Grupo de segurança para o RDS em produção"

  vpc_id = module.vpc.vpc_id  # Usando o ID da VPC do módulo

  // Regra de entrada para IPv6 permitindo todos os TCPs de qualquer lugar
  ingress {
    description = "Permitir tráfego IPv6 TCP de qualquer lugar"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  // Regra de entrada para IPv4 permitindo todos os TCPs de qualquer lugar
  ingress {
    description = "Permitir tráfego IPv4 TCP de qualquer lugar"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}