variable "region" {
  type = string
}

variable "s3_file_storage" {
  description = "The S3 file storage name."
  type        = string
}

variable "s3_codepipeline_artifacts" {
  description = "The S3 codepipeline artifacts name."
  type        = string
}

variable "codebuild_name" {
  description = "Name of codebuild"
  type = string
}

variable "codebuild_role_name" {
  description = "Role of codebuild for run task"
  type = string
}

variable "codepipeline_name" {
  description = "Name of codepipeline"
  type = string
}

variable "codepipeline_role_name" {
  description = "Role of codepipeline for run task"
  type = string
}

variable "vpc_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_execution_role" {
  type = string
}

variable "ecs_task_role" {
  type = string
}

variable "ecr_name" {
  type = string
}

variable repository {
  type = object({
    connection_arn = string
    id = string
    branch = string
  })
}