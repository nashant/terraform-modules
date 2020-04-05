#
# target
#
resource "aws_alb_target_group" "ecs-service" {
  for_each = zipmap(formatlist("%s-%s", local.lb_ports.*.container, local.lb_ports.*.port), local.lb_ports)
  name = format("%s-%s",
    each.key,
    substr(
      md5(
        format(
          "%s%s%s",
          each.value.port,
          var.deregistration_delay,
          var.healthcheck_matcher,
        )
      ),
      0,
      12,
    )
  )
  port                 = each.value.port
  protocol             = each.value.port == 443 ? "HTTPS" : "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = each.value.port == 443 ? "HTTPS" : "HTTP"
    path                = "/"
    interval            = 60
    matcher             = var.healthcheck_matcher
  }
}

