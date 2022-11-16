######################################################################
## Security groups
######################################################################
# PUBLIC
resource "aws_security_group" "alb_sg_public" {
  vpc_id      = "${module.discovery.vpc_id}"
  name        = "${var.app_name}-alb"
  description = "${var.app_name} - ALB Security group"
  tags        = "${merge(var.app_tags, map("Name", format("%s-alb", var.app_name)))}"
}

# Configuration of the firewall - ALB <-> World
resource "aws_security_group_rule" "allow_http_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id  = aws_security_group.alb_sg_public.id
  security_group_id         = aws_security_group.alb_sg_public.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg_public.id
}


# PRIVATE
# Create an application load balancer
resource "aws_lb" "alb" {
  name            = "${var.app_name}-alb-public"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${values(module.discovery.public_subnets_json)}"]

  enable_deletion_protection = false

  tags = "${merge(var.app_tags,
    map("Name", format("%s", var.app_name)),
    map("Tier", "public"),
  )}"
}

# Create a target group for HTTP
resource "aws_lb_target_group" "alb_tg_http" {
  name     = "${var.app_name}-http"
  port     = 8080
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