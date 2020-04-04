#
# target
#
resource "aws_alb_target_group" "ecs-service" {
  name = "${var.application_name}-${substr(
    md5(
      format(
        "%s%s%s",
        var.application_port,
        var.deregistration_delay,
        var.healthcheck_matcher,
      ),
    ),
    0,
    12,
  )}"
  port                 = var.application_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    path                = "/"
    interval            = 60
    matcher             = var.healthcheck_matcher
  }
}

