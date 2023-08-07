module "ecs_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "ecs-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [
    aws_security_group.ecs_alb.id
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name_prefix      = "ecs",
      backend_protocol = "HTTP",
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        path = "/healthz"
      }
    },
  ]

  tags = local.tags
}
