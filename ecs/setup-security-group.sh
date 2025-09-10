#!/bin/bash

# ECS Security Group Setup Script
# This script creates a security group for the robotics-cicd ECS service

set -e

AWS_REGION="eu-north-1"
VPC_ID="vpc-00f325a5edc80a18e"
SECURITY_GROUP_NAME="robotics-cicd-ecs-sg"
SECURITY_GROUP_DESCRIPTION="Security group for robotics-cicd ECS service - allows HTTP traffic on port 8080"

echo "Setting up security group for ECS service..."
echo "Region: $AWS_REGION"
echo "VPC ID: $VPC_ID"

# Check if security group already exists
EXISTING_SG=$(aws ec2 describe-security-groups \
    --region $AWS_REGION \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null || echo "None")

if [ "$EXISTING_SG" != "None" ] && [ "$EXISTING_SG" != "null" ]; then
    echo "Security group already exists: $EXISTING_SG"
    echo "SECURITY_GROUP_ID=$EXISTING_SG"
    exit 0
fi

# Create security group
echo "Creating security group: $SECURITY_GROUP_NAME"
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --region $AWS_REGION \
    --group-name $SECURITY_GROUP_NAME \
    --description "$SECURITY_GROUP_DESCRIPTION" \
    --vpc-id $VPC_ID \
    --query 'GroupId' \
    --output text)

echo "Created security group: $SECURITY_GROUP_ID"

# Add inbound rule for HTTP traffic on port 8080
echo "Adding inbound rule for HTTP traffic on port 8080..."
aws ec2 authorize-security-group-ingress \
    --region $AWS_REGION \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0

echo "Security group setup completed successfully!"
echo "SECURITY_GROUP_ID=$SECURITY_GROUP_ID"
