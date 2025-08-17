#!/bin/bash

# CloudWatch Monitoring Setup Script
# Creates alarms and SNS topics for monitoring the auto-pipe application

set -e

REGION="us-east-1"
ECS_CLUSTER_NAME="auto-pipe-cluster"
ECS_SERVICE_NAME="auto-pipe-service"
SNS_TOPIC_NAME="auto-pipe-alerts"
LOG_GROUP_NAME="/ecs/auto-pipe-app"

echo "📊 Setting up CloudWatch monitoring and alerting..."

# 1. Create SNS Topic
echo "Creating SNS topic for alerts..."
SNS_TOPIC_ARN=$(aws sns create-topic \
    --name $SNS_TOPIC_NAME \
    --region $REGION \
    --query 'TopicArn' \
    --output text)

echo "SNS Topic ARN: $SNS_TOPIC_ARN"

# 2. Create CloudWatch Metric Filter for Errors
echo "Creating metric filter for application errors..."
aws logs put-metric-filter \
    --log-group-name $LOG_GROUP_NAME \
    --filter-name "ErrorCount" \
    --filter-pattern "ERROR" \
    --metric-transformations \
        metricName=ApplicationErrors,metricNamespace=AutoPipe/Application,metricValue=1 \
    --region $REGION

# 3. Create CloudWatch Alarms
echo "Creating CloudWatch alarms..."

# High Error Rate Alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "AutoPipe-HighErrorRate" \
    --alarm-description "High error rate detected in auto-pipe application" \
    --metric-name ApplicationErrors \
    --namespace AutoPipe/Application \
    --statistic Sum \
    --period 300 \
    --threshold 5 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions $SNS_TOPIC_ARN \
    --region $REGION

# ECS Service CPU Utilization
aws cloudwatch put-metric-alarm \
    --alarm-name "AutoPipe-HighCPU" \
    --alarm-description "High CPU utilization in ECS service" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 3 \
    --dimensions Name=ServiceName,Value=$ECS_SERVICE_NAME Name=ClusterName,Value=$ECS_CLUSTER_NAME \
    --alarm-actions $SNS_TOPIC_ARN \
    --region $REGION

# ECS Service Memory Utilization
aws cloudwatch put-metric-alarm \
    --alarm-name "AutoPipe-HighMemory" \
    --alarm-description "High memory utilization in ECS service" \
    --metric-name MemoryUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 85 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 3 \
    --dimensions Name=ServiceName,Value=$ECS_SERVICE_NAME Name=ClusterName,Value=$ECS_CLUSTER_NAME \
    --alarm-actions $SNS_TOPIC_ARN \
    --region $REGION

# ECS Service Running Task Count
aws cloudwatch put-metric-alarm \
    --alarm-name "AutoPipe-ServiceDown" \
    --alarm-description "No running tasks in ECS service" \
    --metric-name RunningTaskCount \
    --namespace AWS/ECS \
    --statistic Average \
    --period 60 \
    --threshold 1 \
    --comparison-operator LessThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=ServiceName,Value=$ECS_SERVICE_NAME Name=ClusterName,Value=$ECS_CLUSTER_NAME \
    --alarm-actions $SNS_TOPIC_ARN \
    --treat-missing-data breaching \
    --region $REGION

echo "✅ Monitoring setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Subscribe to SNS topic: $SNS_TOPIC_ARN"
echo "   - Email: aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol email --notification-endpoint your-email@example.com"
echo "   - Or create a Lambda function for Slack notifications"
echo "2. Test alarms by triggering the /error endpoint"
echo "3. Monitor dashboards in CloudWatch console"
