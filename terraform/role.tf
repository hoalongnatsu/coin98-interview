// Role
resource "aws_iam_role" "aws_codebuild" {
  name = var.codebuild_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "aws_codepipeline" {
  name = var.codepipeline_role_name
  path = "/service-role/"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_execution_role

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

// Policies
resource "aws_iam_role_policy" "aws_codebuild" {
  name   = var.codebuild_role_name
  role   = aws_iam_role.aws_codebuild.id
  policy = file("policies/codebuild.json")
}

resource "aws_iam_role_policy" "aws_codepipeline" {
  name   = var.codepipeline_role_name
  role   = aws_iam_role.aws_codepipeline.id
  policy = file("policies/codepipeline.json")
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = var.ecs_execution_role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_role" {
  name = "PrivateRegistryAuthentication"
  role = aws_iam_role.ecs_execution_role.id
  policy = file("policies/private_registry_authentication.json")
}

resource "aws_iam_role_policy" "ecs_task_role" {
  name   = var.ecs_task_role
  role   = aws_iam_role.ecs_task_role.id
  policy = file("policies/ecs_task.json")
}