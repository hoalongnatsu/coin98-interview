resource "aws_security_group" "ecs_alb" {
  vpc_id = module.vpc.vpc_id
  name   = "allow-http-to-ecs-alb"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "ecs_alb_to_ecs" {
  vpc_id = module.vpc.vpc_id
  name   = "allow-ecs-alb-to-ecs"

  ingress {
    from_port = "3000"
    to_port   = "3000"
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ecs_alb.id
    ]
    description = "Allow access port 3000 from alb"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}