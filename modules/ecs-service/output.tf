output "target_group_arns" {
  value = [for key, val in aws_alb_target_group.ecs-service : val.arn]
}

