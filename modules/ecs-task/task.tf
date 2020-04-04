#
# ECR 
#

resource "aws_ecr_repository" "ecs-task" {
  name = "${var.ecr_prefix}${var.application_name}"
}

#
# get latest active revision
#
data "aws_ecs_task_definition" "ecs-task" {
  task_definition = aws_ecs_task_definition.ecs-task-taskdef.family
  depends_on      = [aws_ecs_task_definition.ecs-task-taskdef]
}

#
# task definition template
#

data "template_file" "ecs-task" {
  template = file(var.task_def_template)

  vars = {
    APPLICATION_NAME    = var.application_name
    APPLICATION_VERSION = var.application_version
    ECR_URL             = aws_ecr_repository.ecs-task.repository_url
    AWS_REGION          = var.aws_region
    CPU_RESERVATION     = var.cpu_reservation
    MEMORY_RESERVATION  = var.memory_reservation
    LOG_GROUP           = var.log_group
  }
}

#
# task definition
#

resource "aws_ecs_task_definition" "ecs-task-taskdef" {
  family                = var.application_name
  container_definitions = data.template_file.ecs-task.rendered
  task_role_arn         = var.task_role_arn
}

# scheduling
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "Run${replace(var.application_name, "-", "")}"
  description         = "runs ecs task"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "schedule" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "Run${replace(var.application_name, "-", "")}"
  arn       = var.cluster_arn
  role_arn  = var.events_role_arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.ecs-task-taskdef.arn
  }
}

