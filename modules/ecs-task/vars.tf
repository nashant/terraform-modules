variable "aws_region" {
}

variable "application_name" {
}

variable "application_version" {
}

variable "cluster_arn" {
}

variable "events_role_arn" {
}

variable "desired_count" {
}

variable "task_def_template" {
}

variable "ecr_prefix" {
  default = ""
}

variable "schedule" {
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

