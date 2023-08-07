region = "ap-southeast-1"

s3_file_storage           = "coin98-interview-file-storage"
s3_codepipeline_artifacts = "coin98-interview-codepipeline-artifacts"
codebuild_name            = "coin98-api-build"
codebuild_role_name       = "coin98-api-build-role"
codepipeline_name         = "coin98-api-pipeline"
codepipeline_role_name    = "coin98-api-pipeline-role"

vpc_name           = "coin98-api"
ecs_cluster_name   = "coin98-api"
ecs_service_name   = "coin98-api"
ecs_execution_role = "coin98-api-execution-role"
ecs_task_role      = "coin98-api-task-role"
ecr_name           = "coin98-api"

repository = {
  connection_arn = ""
  id             = ""
  branch         = ""
}
