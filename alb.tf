######################################################################
## Security groups
######################################################################

resource "aws_security_group" "alb_sg" {
  vpc_id      = module.discovery.vpc_id
  name        = "${var.vpc_name}-alb"
  description = "${var.vpc_name} - ALB Security group"
  tags = {
    Name  = "${var.vpc_name}-alb-sg"
    Owner = "theo.cramez@gmail.com"
  }
}

# Allow all outbound traffic
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}
# Allow inbound HTTP traffic
resource "aws_security_group_rule" "allow_http_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.alb_sg.id
}
# Allow inbound SSH traffic
resource "aws_security_group_rule" "allow_ssh_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.alb_sg.id
}
# Allow inbound netdata traffic
resource "aws_security_group_rule" "allow_netdata_public" {
  type              = "ingress"
  from_port         = 19999
  to_port           = 19999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.alb_sg.id
}


# Create an application load balancer
resource "aws_lb" "alb" {
  name            = "${var.vpc_name}-alb"
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = module.discovery.public_subnets

  enable_deletion_protection = false

  tags = {
    Name  = "${var.vpc_name}-alb"
    Owner = "theo.cramez@gmail.com"
  }
}

# Create a target group for HTTP
resource "aws_lb_target_group" "alb_tg_http" {
  name     = "${var.vpc_name}-http"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${module.discovery.vpc_id}"
}

# Create a target group for netdata
resource "aws_lb_target_group" "alb_tg_netdata" {
  name     = "${var.vpc_name}-netdata"
  port     = 19999
  protocol = "HTTP"
  vpc_id   = "${module.discovery.vpc_id}"
}

# Create an ALB listener for HTTP -> HTTP target group
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.alb_tg_http.arn}"
    type             = "forward"
  }
}

# Create an ALB listener for netdata target group
resource "aws_lb_listener" "alb_listener_netdata" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "19999"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.alb_tg_netdata.arn}"
    type             = "forward"
  }
}