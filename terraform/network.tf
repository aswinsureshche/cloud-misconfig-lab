# ---------------------------------------------------------------------------
# Misconfiguration #3: a security group with SSH open to the entire internet.
#
# A dedicated VPC keeps this fully isolated from anything else in your
# account — nothing here touches your default VPC or any existing resources.
# No EC2 instance is attached to this security group; scanners flag
# unrestricted ingress rules on their own, regardless of attachment, so
# there's no need to pay for a running instance to demonstrate the finding.
# ---------------------------------------------------------------------------

resource "aws_vpc" "lab" {
  cidr_block           = "10.99.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "lab" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.99.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}

resource "aws_security_group" "open_ssh" {
  name        = "${local.name_prefix}-sg"
  description = "Intentionally open when harden=false; restricted to trusted_cidr when harden=true."
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.harden ? [var.trusted_cidr] : ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg"
  }
}

# The VPC's own default security group is a classic, separate finding
# ("default security group should restrict all traffic") — hardening it
# here too, regardless of the harden flag, since there's no reason a lab
# default SG should ever allow anything.
resource "aws_default_security_group" "lab" {
  vpc_id = aws_vpc.lab.id
  # No ingress/egress blocks defined = all rules removed, which is the
  # secure baseline AWS itself recommends for default security groups.
}
