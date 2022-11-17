### Provider definition

provider "aws" {
  region = "${var.aws_region}"
}

### Module Main

module "discovery" {
  source      = "github.com/Lowess/terraform-aws-discovery"

  aws_region  = var.aws_region
  vpc_name    = var.vpc_name
}