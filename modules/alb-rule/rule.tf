variable "listener_arn" {
}

variable "priority" {
}

variable "target_group_arn" {
}

variable "condition_field" {
}

variable "condition_values" {
  type = list(string)
}

resource "aws_lb_listener_rule" "alb_rule" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    field  = var.condition_field
    values = var.condition_values
  }
}

