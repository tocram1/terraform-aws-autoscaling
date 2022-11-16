### PRIVATE

resource "aws_security_group" "base_group_priv" {
  name        = "base_group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name  = "${var.vpc_name}-base_group"
    Owner = "theo.cramez@gmail.com"
  }
}

resource "aws_security_group_rule" "allow_http_priv" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.base_group_priv.id
}

### PUBLIC
resource "aws_security_group" "base_group_pub" {
  name        = "base_group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name  = "${var.vpc_name}-base_group"
    Owner = "theo.cramez@gmail.com"
  }
}

resource "aws_security_group_rule" "allow_http-pub" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.base_group_pub.id
}

resource "aws_autoscaling_group" "asg" {
  name                 = "asg"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.public.id]
  launch_configuration = aws_launch_configuration.lc.name
  health_check_type    = "ELB"
  health_check_grace_period = 300
  target_group_arns    = [aws_lb_target_group.alb_tg_http.arn]
  tags = [
    {
      key                 = "Name"
      value               = "asg"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  alb_target_group_arn   = aws_lb_target_group.alb_tg_http.arn
}