### PRIVATE

resource "aws_security_group" "asg_sg" {
  name        = "private_group"
  description = "Allow HTTP traffic"
  vpc_id      = module.discovery.vpc_id

  tags = {
    Name  = "${var.vpc_name}-private_group"
    Owner = "theo.cramez@gmail.com"
  }
}

resource "aws_security_group_rule" "allow_http_priv" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.asg_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "allow_ssh_priv" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.asg_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "allow_priv_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg_sg.id
}

resource "aws_launch_template" "asg_lt" {
  name_prefix   = "asg-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  key_name = "tocra"
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = module.discovery.private_subnets
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  force_delete        = true

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alb_tg_http.arn]
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  alb_target_group_arn   = aws_lb_target_group.alb_tg_http.arn
}