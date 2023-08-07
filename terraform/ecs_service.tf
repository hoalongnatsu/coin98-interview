resource "aws_ecs_task_definition" "api" {
  family                   = var.ecs_service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_name}",
      "memory" : 512,
      "name" : "api",
      "networkMode" : "awsvpc",
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort" : 3000
        }
      ],
      "environment" : [
        {
          "name" : "S3_BUCKET",
          "value" : var.s3_file_storage
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : var.ecs_cluster_name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : var.ecs_service_name
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  desired_count = 2

  name            = var.ecs_service_name
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.api.arn
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [
      aws_security_group.ecs_alb_to_ecs.id,
    ]
    subnets = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = module.ecs_alb.target_group_arns[0]

    container_name = "api"
    container_port = 3000
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  depends_on = [
    module.ecs_alb
  ]
}
