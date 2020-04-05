output "target_group_arns" {
  value = [
    for target_group in aws_alb_target_group.ecs-service.* :
    target_group.arn
  ]
}

