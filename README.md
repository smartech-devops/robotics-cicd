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

## Future Enhancements
- Blue/green deployments
- Automated testing integration
- Infrastructure as Code (Terraform)
- Advanced monitoring and alerting