resource "aws_instance" "web" {
  for_each          = var.availability_zones
  ami               = var.ami_id
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.public[each.key].id
  key_name          = aws_key_pair.deployer.key_name
  availability_zone = "${var.aws_region}${each.key}"
  source_dest_check = false

  tags = {
    Name    = "${var.vpc_name}-web-${var.aws_region}${each.key}"
    Owner   = "theo.cramez@gmail.com"
  }
}