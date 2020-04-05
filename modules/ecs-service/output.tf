output "target_group_arns" {
  value = aws_alb_target_group.ecs-service[0].arn
}

