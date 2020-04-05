variable "vpc_id" {
}

variable "aws_region" {
}

variable "application_name" {
}

variable "application_containers" {
}

variable "cluster_arn" {
}

variable "efs_id" {
  default = ""
}

variable "service_role_arn" {
}

variable "desired_count" {
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "deregistration_delay" {
  default = 30
}

variable "healthcheck_matcher" {
  default = "200"
}

variable "cpu_reservation" {
}

variable "memory_reservation" {
}

variable "log_group" {
}

variable "task_role_arn" {
  default = ""
}

variable "alb_arn" {
}

