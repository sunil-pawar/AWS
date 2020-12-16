resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
  iam_role        = aws_iam_role.ecs-service-role.arn

  scheduling_strategy = "REPLICA"
 
  load_balancer {
    target_group_arn = aws_alb_target_group.ecs-target-group.arn
    container_name   = "nginx"
    container_port   = 80
  }

 
}