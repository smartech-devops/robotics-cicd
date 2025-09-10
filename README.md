# Robotics CI/CD Demo

## Project Goal
Demonstrate a complete DevOps CI/CD pipeline for containerized Python microservices with automated versioning and AWS cloud deployment.

## Problem Statement
Development teams need a robust, automated way to:
- Build and containerize Python applications
- Version releases automatically
- Deploy to cloud infrastructure
- Ensure production reliability

## Chosen Solution

### Application
- **Python Flask web service** with accessible HTTP endpoints (`/`, `/health`, `/version`)
- **Version tracking** via JSON responses for easy monitoring
- **Multi-stage Docker build** for optimized production images (131MB)
- **Production-ready** with gunicorn, non-root user, and health checks

### CI/CD Pipeline
- **GitHub Actions** for automated workflows
- **Semantic versioning** (Major.Minor.Patch) via git tags
- **AWS ECR** for container image registry
- **AWS ECS Fargate** for serverless container deployment

### Security & Authentication
- **OIDC integration** between GitHub Actions and AWS
- **No long-term credentials** stored in GitHub
- **IAM role-based access** with least privilege

### Deployment & Access
- **ECS Fargate** deployment with public access
- **HTTP endpoints** for version verification and health monitoring
- **Simple demonstration** via web browser or curl commands

## Success Criteria
- ✅ Automated build triggered by code changes
- ✅ Docker images tagged with semantic versions  
- ✅ Images pushed to AWS ECR
- ✅ Automated deployment to ECS with public access
- ✅ Accessible endpoints showing version information
- ✅ Complete pipeline demonstration via HTTP requests

## Architecture
```
GitHub → Actions → Docker Build → ECR → ECS Deployment
```

### ECS Infrastructure Design
**Current AWS Environment:**
- Region: eu-north-1
- VPC: vpc-00f325a5edc80a18e (default)
- Public Subnets: 3 available for high availability

**ECS Setup:**
1. **ECS Cluster**: `robotics-cicd-demo-cluster` (Fargate)
2. **Task Definition**: Containerized Flask web service
3. **Security Group**: HTTP access on port 8080
4. **ECS Service**: 1 task with public IP for demo access

**Infrastructure Components:**
- **Cluster**: Serverless Fargate compute
- **Networking**: Public subnets with internet gateway
- **Security**: Security group allowing HTTP traffic
- **Service Discovery**: Public IP assignment for direct access
- **Cost**: ~$0.10-0.20/hour for demo task

## Future Enhancements
- Blue/green deployments
- Automated testing integration
- Infrastructure as Code (Terraform)
- Advanced monitoring and alerting