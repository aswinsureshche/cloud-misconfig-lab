terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Local state on purpose — this is a short-lived personal lab, not a team
  # environment. Never commit terraform.tfstate; it can contain resource
  # details. See ../.gitignore.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "cloud-misconfig-lab"
      ManagedBy = "terraform"
      Purpose   = "portfolio-security-lab"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = "${var.project_name}-${random_id.suffix.hex}"
}
