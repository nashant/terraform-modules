locals {
  containers = flatten([
    for container in var.application_containers : [
      merge(
        {
          essential = true
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = var.log_group
              awslogs-region        = var.aws_region
              awslogs-stream-prefix = container.name
            }
          }
        },
        container
      )
    ]
  ])

  volumes = flatten([
    for container in local.containers : [
      for mountPoint in container.mountPoints : [
        merge({ container : container.name }, mountPoint)
      ]
    ]
  ])

  lb_ports = flatten([
    for container in local.containers : [
      for portMapping in container.portMappings : [
        {
          container = container.name
          port      = portMapping.containerPort
        }
      ]
    ]
  ])
}

#
# ECR 
#

resource "aws_ecr_repository" "ecs-service" {
  name = var.application_name
}

#
# task definition
#

resource "aws_ecs_task_definition" "ecs-task" {
  family                = var.application_name
  container_definitions = jsonencode(local.containers)
  task_role_arn         = var.task_role_arn

  dynamic "volume" {
    for_each = var.efs_id == "" ? local.volumes : []
    content {
      name      = volume.value["sourceVolume"]
      host_path = format("%s/%s/%s", var.mount_rootdir, volume.value["container"], volume.value["sourceVolume"])
    }
  }

  dynamic "volume" {
    for_each = var.efs_id != "" ? local.volumes : []
    content {
      name = volume.value["sourceVolume"]
      efs_volume_configuration {
        file_system_id = var.efs_id
        root_directory = format("%s/%s/%s", var.mount_rootdir, volume.value["container"], volume.value["sourceVolume"])
      }
    }
  }
}

#
# ecs service
#

resource "aws_ecs_service" "ecs-service" {
  name                               = var.application_name
  cluster                            = var.cluster_arn
  task_definition                    = aws_ecs_task_definition.ecs-task.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  dynamic "load_balancer" {
    for_each = flatten([
      for lb_port in local.lb_ports :
      merge(
        lb_port,
        {
          target_group_arn = aws_alb_target_group.ecs-service[format("%s-%s", lb_port.container, lb_port.port)].arn
        }
      )
    ])
    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = load_balancer.value["container"]
      container_port   = load_balancer.value["port"]
    }
  }

  depends_on = [null_resource.alb_exists]
}

resource "null_resource" "alb_exists" {
  triggers = {
    alb_name = var.alb_arn
  }
}

