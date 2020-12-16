resource "aws_ecs_task_definition" "service" {
  family                = "service"
  network_mode = "host"
  container_definitions = <<TASK_DEFINITION
 [
        {
            "dnsSearchDomains": null,
            "environmentFiles": null,
            "logConfiguration": null,
            "entryPoint": null,
            "portMappings": [
                {
                    "hostPort": 80,
                    "protocol": "tcp",
                    "containerPort": 80
                }
            ],
            "cpu": 0,
            "memory": 128,
            "image": "nginx:latest",
            "name": "nginx"
        }
  ]
  TASK_DEFINITION
  


}