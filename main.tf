### Provider definition

provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

### Module Main

module "discovery" {
  source      = "github.com/Lowess/terraform-aws-discovery"

  aws_region  = var.aws_region
  vpc_name    = var.vpc_name
}