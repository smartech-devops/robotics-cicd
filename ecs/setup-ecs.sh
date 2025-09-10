#!/bin/bash

# ECS Cluster and Service Setup Script
# This script creates the ECS cluster and service for the robotics-cicd demo

set -e

AWS_REGION="eu-north-1"
CLUSTER_NAME="robotics-cicd-demo-cluster"
SERVICE_NAME="robotics-cicd-demo-service"
TASK_DEFINITION_FAMILY="robotics-cicd-demo-task"
VPC_ID="vpc-00f325a5edc80a18e"

echo "Setting up ECS infrastructure..."
echo "Region: $AWS_REGION"
echo "Cluster: $CLUSTER_NAME"

# Get public subnets from the default VPC
echo "Getting public subnets from VPC: $VPC_ID"
PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
    --region $AWS_REGION \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=map-public-ip-on-launch,Values=true" \
    --query 'Subnets[].SubnetId' \
    --output text | tr '\t' ',')

if [ -z "$PUBLIC_SUBNETS" ]; then
    echo "Error: No public subnets found in VPC $VPC_ID"
    exit 1
fi

echo "Found public subnets: $PUBLIC_SUBNETS"

# Get security group ID (should be created by setup-security-group.sh)
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --filters "Name=group-name,Values=robotics-cicd-ecs-sg" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null)

if [ "$SECURITY_GROUP_ID" == "None" ] || [ -z "$SECURITY_GROUP_ID" ]; then
    echo "Error: Security group 'robotics-cicd-ecs-sg' not found. Run setup-security-group.sh first."
    exit 1
fi

echo "Using security group: $SECURITY_GROUP_ID"

# Create ECS cluster if it doesn't exist
echo "Creating ECS cluster: $CLUSTER_NAME"
EXISTING_CLUSTER=$(aws ecs describe-clusters \
    --region $AWS_REGION \
    --clusters $CLUSTER_NAME \
    --query 'clusters[0].status' \
    --output text 2>/dev/null || echo "INACTIVE")

if [ "$EXISTING_CLUSTER" == "ACTIVE" ]; then
    echo "Cluster already exists and is active: $CLUSTER_NAME"
else
    aws ecs create-cluster \
        --region $AWS_REGION \
        --cluster-name $CLUSTER_NAME \
        --capacity-providers FARGATE \
        --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1
    
    echo "Created ECS cluster: $CLUSTER_NAME"
fi

# Create CloudWatch log group for ECS logs
LOG_GROUP_NAME="/ecs/robotics-cicd-demo"
echo "Creating CloudWatch log group: $LOG_GROUP_NAME"
aws logs create-log-group \
    --region $AWS_REGION \
    --log-group-name $LOG_GROUP_NAME 2>/dev/null || echo "Log group already exists"

# Register task definition (this will be updated by the CI/CD pipeline)
echo "Registering initial task definition..."
cd "$(dirname "$0")"  # Change to the ecs directory
aws ecs register-task-definition \
    --region $AWS_REGION \
    --cli-input-json file://task-definition.json

echo "Task definition registered successfully"

# Create ECS service if it doesn't exist
echo "Setting up ECS service: $SERVICE_NAME"
EXISTING_SERVICE=$(aws ecs describe-services \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME \
    --query 'services[0].status' \
    --output text 2>/dev/null || echo "INACTIVE")

if [ "$EXISTING_SERVICE" == "ACTIVE" ]; then
    echo "Service already exists: $SERVICE_NAME"
else
    # Create service with network configuration
    aws ecs create-service \
        --region $AWS_REGION \
        --cluster $CLUSTER_NAME \
        --service-name $SERVICE_NAME \
        --task-definition $TASK_DEFINITION_FAMILY \
        --desired-count 1 \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[$PUBLIC_SUBNETS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
        --health-check-grace-period-seconds 120

    echo "Created ECS service: $SERVICE_NAME"
fi

echo "ECS setup completed successfully!"
echo "Cluster: $CLUSTER_NAME"
echo "Service: $SERVICE_NAME"
echo "Task Definition: $TASK_DEFINITION_FAMILY"

# Wait for service to be stable (optional)
echo "Waiting for service to become stable (this may take a few minutes)..."
aws ecs wait services-stable \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --services $SERVICE_NAME

echo "Service is now stable and running!"

# Get the public IP of the running task
echo "Getting public IP address of the running task..."
TASK_ARN=$(aws ecs list-tasks \
    --region $AWS_REGION \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --query 'taskArns[0]' \
    --output text)

if [ "$TASK_ARN" != "None" ] && [ -n "$TASK_ARN" ]; then
    ENI_ID=$(aws ecs describe-tasks \
        --region $AWS_REGION \
        --cluster $CLUSTER_NAME \
        --tasks $TASK_ARN \
        --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
        --output text)

    if [ -n "$ENI_ID" ]; then
        PUBLIC_IP=$(aws ec2 describe-network-interfaces \
            --region $AWS_REGION \
            --network-interface-ids $ENI_ID \
            --query 'NetworkInterfaces[0].Association.PublicIp' \
            --output text)

        if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "None" ]; then
            echo "========================================="
            echo "🚀 Application is accessible at:"
            echo "Main endpoint:    http://$PUBLIC_IP:8080/"
            echo "Health endpoint:  http://$PUBLIC_IP:8080/health"
            echo "Version endpoint: http://$PUBLIC_IP:8080/version"
            echo "========================================="
        fi
    fi
fi
