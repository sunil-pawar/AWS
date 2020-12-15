#!/bin/bash
sudo cat << 'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=test_ecs_cluster
ECS_LOGLEVEL=debug
EOF
sudo yum insatll update -y
sudo yum install htop -y
sudo apt-get install python3.7 -y 
sudo yum install python37  -y 