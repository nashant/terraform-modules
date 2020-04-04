# certificate
data "aws_acm_certificate" "certificate" {
  domain   = var.domain
  statuses = ["ISSUED", "PENDING_VALIDATION"]
}

# alb listener (https)
resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = var.alb_arn
  port              = var.alb_port
  protocol          = var.alb_protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}

