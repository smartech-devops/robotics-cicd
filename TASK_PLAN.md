# DevOps CI/CD Technical Test - Task Plan

**Time Allocation: 2.5 Hours Total (150 minutes)**  
**Goal**: Create a working CI/CD pipeline with Docker, versioning, and AWS deployment

## Time Breakdown:
- **Planning & Research**: 15-20 min (COMPLETED)
- **Development & Implementation**: 110-120 min
- **Troubleshooting Buffer**: 15-20 min
- **Future Enhancement Discussion**: 10-15 min

## Overview
Build a complete DevOps solution demonstrating:
- GitHub repository with proper setup
- Python application containerization
- CI/CD pipeline with semantic versioning
- AWS cloud deployment with ECR and ECS

---

## **Phase 1: Development Environment Setup** ⏱️ 35-45 minutes

### High-Level Task: Set up development environment and AWS integration

#### Subtasks:
1. **Configure existing GitHub repository with PAT authentication** 
   - Repository: `robotics-cicd` (already exists)
   - Generate GitHub Personal Access Token for local dev
   - Configure git with PAT (avoid SSH for security)
   - Ensure proper .gitignore and README.md exist

2. **Generate AWS credentials for CLI access**
   - Create IAM user for local development
   - Generate access keys
   - Configure AWS CLI with credentials
   - Test access with `aws sts get-caller-identity`

3. **Configure OIDC provider in AWS for GitHub Actions**
   - Create OIDC identity provider in IAM
   - Configure with GitHub's thumbprint and audience
   - Set up trust relationship for GitHub Actions

4. **Create IAM role for OIDC with necessary permissions**
   - Create role with OIDC trust policy
   - Attach policies: ECR, ECS, CloudFormation permissions
   - Test role assumption from GitHub Actions

---

## **Phase 2: Application Development** ⏱️ 25-35 minutes

### High-Level Task: Build the Python application with Docker support

#### Subtasks:
1. **Create hello_world.py Python script**
   - Simple script that prints "Hello from CI/CD!"
   - Include version information in output
   - Make it web-ready (basic Flask app for demo)

2. **Write Dockerfile for the application**
   - Use official Python slim image
   - Multi-stage build for optimization
   - Include health check
   - Non-root user for security

3. **Add requirements.txt if needed**
   - List minimal dependencies (Flask if web app)
   - Pin versions for reproducibility

4. **Test Docker build locally**
   - Build image with test tag
   - Run container to verify functionality
   - Check image size and layers

---

## **Phase 3: CI/CD Pipeline Implementation** ⏱️ 60-75 minutes

### High-Level Task: Implement CI/CD pipeline with versioning

#### Subtasks:
1. **Create GitHub Actions workflow file**
   - `.github/workflows/ci-cd.yml`
   - Trigger on push to main branch
   - Set up job dependencies and matrix builds

2. **Implement semantic versioning strategy**
   - Use git tags for version tracking
   - Auto-increment patch version on each build
   - Format: Major.Minor.Patch (e.g., 1.0.0, 1.0.1)
   - Tag Docker images with same version

3. **Configure ECR repository for Docker images**
   - Create ECR repository via AWS CLI or Console
   - Set up repository policies
   - Configure lifecycle policies for cleanup

4. **Set up Docker build and push to ECR**
   - Multi-architecture builds (amd64)
   - Layer caching for faster builds
   - Image scanning for security
   - Tag with version and 'latest'

5. **Configure simple deployment target (ECS Fargate)**
   - Create ECS cluster
   - Define task definition with versioned image
   - Set up ECS service for deployment
   - Configure basic networking (public subnet)

6. **Test complete pipeline end-to-end**
   - Push change to trigger pipeline
   - Verify build, tag, and deployment
   - Confirm running service in ECS

---

## **Phase 4: Documentation & Demo Prep** ⏱️ 15-25 minutes

### High-Level Task: Document the solution and prepare for demo

#### Subtasks:
1. **Update README with architecture explanation**
   - Pipeline architecture diagram (text-based)
   - Service explanations and connections
   - Versioning strategy documentation
   - Build optimization notes

2. **Prepare demo script**
   - Sequence of changes to demonstrate
   - Expected outputs and where to find them
   - Rollback and troubleshooting notes

---

## **Key Technical Decisions for Speed & Success**

### Architecture Choices:
- **Versioning**: Git tags + GitHub Actions auto-increment (simple, reliable)
- **Container Registry**: AWS ECR (native integration, secure)
- **Deployment Target**: ECS Fargate (managed, no server maintenance)
- **Authentication**: OIDC (secure, no long-term credentials)
- **Workflow**: GitHub Actions (integrated with repo, free tier)

### Optimization Strategies:
- **Docker**: Multi-stage builds, layer caching, slim base images
- **Pipeline**: Parallel jobs, artifact caching, conditional steps
- **AWS**: Spot instances for builds, lifecycle policies for cleanup

### Security Considerations:
- No hardcoded credentials
- OIDC for temporary credentials
- Image scanning in ECR
- Non-root containers
- Minimal IAM permissions

---

## **Success Criteria**
- [ ] Repository accessible and properly configured
- [ ] Docker image builds and runs successfully
- [ ] Versioning works automatically
- [ ] Pipeline triggers on code changes
- [ ] Image pushed to ECR with correct tags
- [ ] Application deployed and accessible
- [ ] Full demo can be performed

---

## **Troubleshooting Buffer** ⏱️ 15-20 minutes
Reserve time for:
- AWS permission issues
- Docker build failures
- GitHub Actions debugging
- Network connectivity problems
- Service startup issues

---

## **Future Enhancement Discussion** ⏱️ 10-15 minutes
Prepare to discuss:
- **Production Readiness**: Blue/green deployments, automated testing, security scanning
- **Infrastructure as Code**: Terraform/CloudFormation for reproducible infrastructure
- **Observability**: CloudWatch, X-Ray tracing, application metrics
- **Security**: Container scanning, secrets management, least privilege IAM
- **Scalability**: Auto-scaling, load balancing, multi-region deployment
- **Cost Optimization**: Spot instances, rightsizing, lifecycle policies

---

## **Execution Notes**
- **MVP First**: Working solution beats perfect solution
- **Phase Gates**: Complete and test each phase before proceeding
- **Time Tracking**: Monitor progress against plan, adjust scope if needed
- **Documentation**: Keep notes for troubleshooting and demo
- **Rollback Ready**: Have plan B for each component