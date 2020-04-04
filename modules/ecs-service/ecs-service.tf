#
# ECR 
#

resource "aws_ecr_repository" "ecs-service" {
  name = var.application_name
}

#
# get latest active revision
#
data "aws_ecs_task_definition" "ecs-service" {
  task_definition = aws_ecs_task_definition.ecs-service-taskdef.family
  depends_on      = [aws_ecs_task_definition.ecs-service-taskdef]
}

#
# task definition template
#

data "template_file" "ecs-service" {
  template = file("${path.module}/ecs-service.json")

  vars = {
    APPLICATION_NAME    = var.application_name
    APPLICATION_PORT    = var.application_port
    APPLICATION_VERSION = var.application_version
    ECR_URL             = aws_ecr_repository.ecs-service.repository_url
    AWS_REGION          = var.aws_region
    CPU_RESERVATION     = var.cpu_reservation
    MEMORY_RESERVATION  = var.memory_reservation
    LOG_GROUP           = var.log_group
  }
}

#
# task definition
#

resource "aws_ecs_task_definition" "ecs-service-taskdef" {
  family                = var.application_name
  container_definitions = data.template_file.ecs-service.rendered
  task_role_arn         = var.task_role_arn
}

#
# ecs service
#

resource "aws_ecs_service" "ecs-service" {
  name    = var.application_name
  cluster = var.cluster_arn
  task_definition = "${aws_ecs_task_definition.ecs-service-taskdef.family}:${max(
    aws_ecs_task_definition.ecs-service-taskdef.revision,
    data.aws_ecs_task_definition.ecs-service.revision,
  )}"
  iam_role                           = var.service_role_arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs-service.id
    container_name   = var.application_name
    container_port   = var.application_port
  }

  depends_on = [null_resource.alb_exists]
}

resource "null_resource" "alb_exists" {
  triggers = {
    alb_name = var.alb_arn
  }
}

