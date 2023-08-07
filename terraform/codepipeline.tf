resource "aws_codebuild_project" "build" {
  name         = var.codebuild_name
  service_role = aws_iam_role.aws_codebuild.arn

  artifacts {
    name      = aws_s3_bucket.codepipeline_artifacts.id
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  tags = local.tags
}

resource "aws_codepipeline" "pipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.aws_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = [
        "SourceArtifact"
      ]

      configuration = {
        ConnectionArn    = var.repository.connection_arn
        FullRepositoryId = var.repository.id
        BranchName       = var.repository.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name      = "Build"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact",
      ]

      configuration = {
        "EnvironmentVariables" = jsonencode([
          {
            name  = "AWS_DEFAULT_REGION"
            type  = "PLAINTEXT"
            value = var.region
          },
          {
            name  = "AWS_ACCOUNT_ID"
            type  = "PLAINTEXT"
            value = data.aws_caller_identity.current.account_id
          },
          {
            name  = "IMAGE_REPO_NAME"
            type  = "PLAINTEXT"
            value = var.ecr_name
          },
        ])
        "ProjectName" = var.codebuild_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name      = "Deploy"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "ECS"
      run_order = 1
      version   = "1"
      input_artifacts = [
        "BuildArtifact",
      ]

      configuration = {
        "ClusterName" = var.ecs_cluster_name
        "ServiceName" = aws_ecs_service.api.name
        "FileName"    = "imagedefinitions.json"
      }
    }
  }

  tags = local.tags
}
