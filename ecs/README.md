# ECS Infrastructure Setup

This directory contains all the necessary files and scripts to deploy the robotics-cicd Flask application to AWS ECS Fargate.

## Files Overview

- `task-definition.json` - ECS task definition for the Flask application
- `setup-security-group.sh` - Creates security group for ECS service
- `setup-ecs.sh` - Sets up ECS cluster, service, and registers task definition
- `setup-infrastructure.sh` - Master script that runs all setup components
- `README.md` - This documentation file

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Permissions** to create/manage:
   - ECS clusters and services
   - EC2 security groups
   - CloudWatch log groups
   - IAM roles (ecsTaskExecutionRole should exist)
3. **ECR repository** `robotics-cicd` should exist with at least one image

## Quick Start

### 1. Setup Infrastructure

Run the master setup script to create all required AWS resources:

```bash
./setup-infrastructure.sh
```

This will:
- Create security group for HTTP traffic on port 8080
- Create ECS cluster `robotics-cicd-demo-cluster`
- Register the task definition
- Create ECS service `robotics-cicd-demo-service`
- Deploy the application and show the public endpoint

### 2. Automatic Deployment via CI/CD

Once the infrastructure is set up, any push to the `main` branch will automatically:
1. Build and test the Docker image
2. Push to ECR with version tag
3. Deploy to ECS with the new image
4. Show the public endpoint in the GitHub Actions log

## Infrastructure Details

### ECS Configuration
- **Cluster**: `robotics-cicd-demo-cluster` (Fargate)
- **Service**: `robotics-cicd-demo-service`
- **Task Definition**: `robotics-cicd-demo-task`
- **Resources**: 256 CPU units, 512 MB memory
- **Network**: Public subnets with internet access

### Security
- **Security Group**: Allows inbound HTTP traffic on port 8080
- **IAM Role**: Uses `ecsTaskExecutionRole` for container execution
- **VPC**: Uses default VPC with public subnets

### Monitoring
- **CloudWatch Logs**: `/ecs/robotics-cicd-demo` log group
- **Health Checks**: Container health check on `/health` endpoint
- **ECS Service**: Monitors and maintains desired task count

## Manual Operations

### Check Service Status
```bash
aws ecs describe-services \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --services robotics-cicd-demo-service
```

### View Logs
```bash
aws logs tail /ecs/robotics-cicd-demo --follow
```

### Get Public IP
```bash
# Get task ARN
TASK_ARN=$(aws ecs list-tasks \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --service-name robotics-cicd-demo-service \
    --query 'taskArns[0]' \
    --output text)

# Get ENI ID
ENI_ID=$(aws ecs describe-tasks \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --tasks $TASK_ARN \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

# Get public IP
aws ec2 describe-network-interfaces \
    --region eu-north-1 \
    --network-interface-ids $ENI_ID \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text
```

### Force New Deployment
```bash
aws ecs update-service \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --service robotics-cicd-demo-service \
    --force-new-deployment
```

## Cleanup

To remove all ECS resources:

```bash
# Delete service
aws ecs update-service \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --service robotics-cicd-demo-service \
    --desired-count 0

aws ecs delete-service \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --service robotics-cicd-demo-service

# Delete cluster
aws ecs delete-cluster \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster

# Delete security group
aws ec2 delete-security-group \
    --region eu-north-1 \
    --group-name robotics-cicd-ecs-sg

# Delete log group
aws logs delete-log-group \
    --region eu-north-1 \
    --log-group-name /ecs/robotics-cicd-demo
```

## Troubleshooting

### Common Issues

1. **Service fails to start**: Check CloudWatch logs for container errors
2. **Cannot access endpoint**: Verify security group allows port 8080
3. **Task keeps restarting**: Check health check configuration and application logs
4. **Permission denied**: Ensure ecsTaskExecutionRole exists and has proper permissions

### Useful Commands

```bash
# Check service events
aws ecs describe-services \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --services robotics-cicd-demo-service \
    --query 'services[0].events[0:5]'

# Check task definition
aws ecs describe-task-definition \
    --region eu-north-1 \
    --task-definition robotics-cicd-demo-task

# List running tasks
aws ecs list-tasks \
    --region eu-north-1 \
    --cluster robotics-cicd-demo-cluster \
    --service-name robotics-cicd-demo-service
```
