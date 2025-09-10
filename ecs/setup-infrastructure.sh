#!/bin/bash

# Master ECS Infrastructure Setup Script
# This script orchestrates the complete ECS infrastructure setup

set -e

echo "=========================================="
echo "🚀 Setting up ECS Infrastructure"
echo "=========================================="

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

echo "Step 1: Setting up Security Group..."
./setup-security-group.sh

echo -e "\nStep 2: Setting up ECS Cluster and Service..."
./setup-ecs.sh

echo -e "\n=========================================="
echo "✅ ECS Infrastructure setup completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Push code changes to trigger CI/CD pipeline"
echo "2. The pipeline will automatically deploy to ECS"
echo "3. Access your application via the public IP shown above"
echo ""
echo "To manually trigger a deployment:"
echo "  git add ."
echo "  git commit -m 'Deploy to ECS'"
echo "  git push origin main"
