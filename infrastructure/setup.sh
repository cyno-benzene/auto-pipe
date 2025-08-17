#!/bin/bash

# AWS Infrastructure Setup Script
# This script creates the necessary AWS resources for the auto-pipe project

set -e

# Configuration
REGION="us-east-1"
ECR_REPO_NAME="auto-pipe-api"
ECS_CLUSTER_NAME="auto-pipe-cluster"
ECS_SERVICE_NAME="auto-pipe-service"
LOG_GROUP_NAME="/ecs/auto-pipe-app"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🚀 Setting up AWS infrastructure for Auto-Pipe"
echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"

# 1. Create ECR Repository
echo "📦 Creating ECR repository..."
if aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $REGION >/dev/null 2>&1; then
    echo "ECR repository $ECR_REPO_NAME already exists"
else
    aws ecr create-repository \
        --repository-name $ECR_REPO_NAME \
        --region $REGION \
        --image-scanning-configuration scanOnPush=true
    echo "ECR repository $ECR_REPO_NAME created"
fi

# 2. Create CloudWatch Log Group
echo "📊 Creating CloudWatch log group..."
if aws logs describe-log-groups --log-group-name-prefix $LOG_GROUP_NAME --region $REGION --query 'logGroups[0].logGroupName' --output text | grep -q $LOG_GROUP_NAME; then
    echo "Log group $LOG_GROUP_NAME already exists"
else
    aws logs create-log-group \
        --log-group-name $LOG_GROUP_NAME \
        --region $REGION
    echo "Log group $LOG_GROUP_NAME created"
fi

# 3. Create ECS Cluster
echo "🐳 Creating ECS cluster..."
if aws ecs describe-clusters --clusters $ECS_CLUSTER_NAME --region $REGION --query 'clusters[0].status' --output text | grep -q ACTIVE; then
    echo "ECS cluster $ECS_CLUSTER_NAME already exists"
else
    aws ecs create-cluster \
        --cluster-name $ECS_CLUSTER_NAME \
        --region $REGION
    echo "ECS cluster $ECS_CLUSTER_NAME created"
fi

# 4. Create IAM roles if they don't exist
echo "🔐 Setting up IAM roles..."

# ECS Task Execution Role
if aws iam get-role --role-name ecsTaskExecutionRole >/dev/null 2>&1; then
    echo "ecsTaskExecutionRole already exists"
else
    echo "Creating ecsTaskExecutionRole..."
    aws iam create-role \
        --role-name ecsTaskExecutionRole \
        --assume-role-policy-document file://trust-policy-ecs.json
    
    aws iam attach-role-policy \
        --role-name ecsTaskExecutionRole \
        --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
fi

# ECS Task Role
if aws iam get-role --role-name ecsTaskRole >/dev/null 2>&1; then
    echo "ecsTaskRole already exists"
else
    echo "Creating ecsTaskRole..."
    aws iam create-role \
        --role-name ecsTaskRole \
        --assume-role-policy-document file://trust-policy-ecs.json
fi

# GitHub Actions Role
if aws iam get-role --role-name GitHubActionsDeployRole >/dev/null 2>&1; then
    echo "GitHubActionsDeployRole already exists"
else
    echo "Creating GitHubActionsDeployRole..."
    # Note: You need to update the trust policy with your GitHub repo details
    aws iam create-role \
        --role-name GitHubActionsDeployRole \
        --assume-role-policy-document file://trust-policy-github.json
    
    aws iam attach-role-policy \
        --role-name GitHubActionsDeployRole \
        --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
    
    aws iam put-role-policy \
        --role-name GitHubActionsDeployRole \
        --policy-name ECSDeployPolicy \
        --policy-document file://ecs-deploy-policy.json
fi

echo "✅ Infrastructure setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Update taskdef.template.json with your account ID: $ACCOUNT_ID"
echo "2. Set up GitHub secrets:"
echo "   - AWS_ROLE_ARN: arn:aws:iam::$ACCOUNT_ID:role/GitHubActionsDeployRole"
echo "   - SLACK_WEBHOOK_URL: Your Slack webhook URL"
echo "3. Create an ECS service (manually or with the create-service.sh script)"
echo "4. Push your code to GitHub to trigger the CI/CD pipeline"
