# Auto-Pipe: Automated Cloud Deployment Pipeline

A production-ready FastAPI application with complete CI/CD pipeline, demonstrating modern DevOps practices including containerization, automated testing, secure deployments to AWS ECS, and comprehensive monitoring.

## 🎯 Project Goals

This project demonstrates proficiency in:
- **Containerization**: Docker multi-stage builds and optimization
- **CI/CD**: GitHub Actions with secure OIDC authentication
- **Cloud Infrastructure**: AWS ECS Fargate, ECR, CloudWatch
- **Security**: IAM roles, OIDC federation, secrets management
- **Monitoring**: CloudWatch alarms, SNS notifications, Slack integration
- **Code Quality**: Automated testing, linting, and formatting

## 🏗️ Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   GitHub    │───▶│    GitHub    │───▶│     AWS     │
│ Repository  │    │   Actions    │    │    Cloud    │
└─────────────┘    └──────────────┘    └─────────────┘
                          │                     │
                          ▼                     ▼
                   ┌──────────────┐    ┌─────────────┐
                   │     ECR      │    │ ECS Fargate │
                   │   Registry   │    │   Service   │
                   └──────────────┘    └─────────────┘
                                              │
                                              ▼
                                     ┌─────────────┐
                                     │ CloudWatch  │
                                     │ Monitoring  │
                                     └─────────────┘
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Docker installed locally
- Python 3.11+
- GitHub account with repository

### Local Development

1. **Clone and setup**:
   ```bash
   git clone <your-repo-url>
   cd auto-pipe
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Run tests**:
   ```bash
   pytest tests/ -v
   ```

3. **Start locally with Docker**:
   ```bash
   docker compose up --build
   curl http://localhost:8000/health
   ```

4. **Access API documentation**:
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## ☁️ AWS Infrastructure Setup

### 1. Initial Setup

```bash
cd infrastructure
./setup.sh
```

This script creates:
- ECR repository for container images
- ECS cluster for running containers
- IAM roles for secure access
- CloudWatch log groups

### 2. Configure GitHub OIDC

1. **Create OIDC Provider** (one-time per AWS account):
   ```bash
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   ```

2. **Update trust policy** in `infrastructure/trust-policy-github.json`:
   ```json
   {
     "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/auto-pipe:ref:refs/heads/main"
   }
   ```

3. **Get your AWS Account ID**:
   ```bash
   aws sts get-caller-identity --query Account --output text
   ```

4. **Update task definition** in `taskdef.template.json`:
   Replace `ACCOUNT_ID` with your actual AWS account ID.

### 3. Setup Monitoring

```bash
./monitoring-setup.sh
```

### 4. Configure GitHub Secrets

In your GitHub repository settings, add these secrets:

| Secret | Value | Description |
|--------|-------|-------------|
| `AWS_ROLE_ARN` | `arn:aws:iam::ACCOUNT_ID:role/GitHubActionsDeployRole` | IAM role for deployment |
| `SLACK_WEBHOOK_URL` | `https://hooks.slack.com/services/...` | Slack notifications |

## 📦 Container Details

### Multi-stage Dockerfile Features:
- **Security**: Non-root user, minimal attack surface
- **Performance**: Optimized layer caching
- **Health Checks**: Built-in container health monitoring
- **Size**: Slim Python base image

### Docker Compose Features:
- **Development**: Hot-reload for code changes
- **Networking**: Isolated container networking
- **Health Checks**: Service dependency management

## 🔄 CI/CD Pipeline

### Pipeline Stages:

1. **Test Stage**:
   - Code linting with flake8 and black
   - Unit tests with pytest
   - Code coverage reporting

2. **Build & Push Stage**:
   - Multi-architecture Docker build
   - Image vulnerability scanning
   - Push to ECR with tags

3. **Deploy Stage**:
   - ECS task definition update
   - Rolling deployment
   - Health check validation

4. **Notification Stage**:
   - Slack notifications for success/failure
   - Deployment status tracking

### Security Features:
- **OIDC Authentication**: No long-lived AWS credentials
- **Least Privilege**: Minimal IAM permissions
- **Secrets Management**: GitHub Secrets integration
- **Image Scanning**: ECR vulnerability scanning

## 📊 Monitoring & Alerting

### CloudWatch Alarms:
- **High Error Rate**: >5 errors in 10 minutes
- **High CPU Usage**: >80% for 15 minutes
- **High Memory Usage**: >85% for 15 minutes
- **Service Down**: No running tasks

### Metrics Tracked:
- Application response times
- Error rates and types
- Resource utilization
- Container health status

### Notification Channels:
- Slack webhooks for real-time alerts
- SNS topics for email notifications
- CloudWatch dashboards for visualization

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information and links |
| GET | `/health` | Health check for load balancers |
| GET | `/items/{id}` | Retrieve item by ID |
| POST | `/items` | Create new item |
| GET | `/error` | Test endpoint for monitoring |
| GET | `/docs` | Interactive API documentation |

## 🧪 Testing

### Running Tests:
```bash
# Unit tests
pytest tests/ -v

# With coverage
pytest tests/ --cov=app --cov-report=html

# Linting
flake8 app tests
black --check app tests
```

### Test Categories:
- **Unit Tests**: Individual function testing
- **Integration Tests**: API endpoint testing
- **Health Checks**: Service availability testing
- **Error Handling**: Exception scenarios

## 🔒 Security Best Practices

### Implemented Security Measures:
- **Container Security**: Non-root user, minimal image
- **AWS Security**: IAM roles, OIDC federation
- **Network Security**: VPC isolation, security groups
- **Secrets Management**: AWS Secrets Manager integration
- **Image Security**: ECR vulnerability scanning

### Security Checklist:
- [ ] Rotate IAM role credentials regularly
- [ ] Enable AWS CloudTrail for audit logging
- [ ] Configure VPC security groups properly
- [ ] Keep container images updated
- [ ] Monitor security alerts

## 📈 Performance Optimization

### Container Optimization:
- Multi-stage builds for smaller images
- Layer caching for faster builds
- Health checks for reliability
- Resource limits for stability

### Application Optimization:
- Async/await for better concurrency
- Pydantic for data validation
- Structured logging for observability
- Graceful shutdown handling

## 🚀 Deployment Strategies

### Current: Rolling Deployment
- Zero-downtime deployments
- Health check validation
- Automatic rollback on failure

### Future Enhancements:
- Blue/Green deployments
- Canary releases
- A/B testing capability
- Performance-based rollbacks

## 📝 Development Workflow

1. **Feature Development**:
   ```bash
   git checkout -b feature/new-feature
   # Make changes
   pytest tests/
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

2. **Pull Request**:
   - Automated tests run
   - Code review required
   - Merge to main triggers deployment

3. **Deployment**:
   - Automatic deployment to production
   - Health checks validate deployment
   - Notifications sent to team

## 🐛 Troubleshooting

### Common Issues:

1. **ECS Service Won't Start**:
   - Check task definition IAM roles
   - Verify ECR repository permissions
   - Review CloudWatch logs

2. **GitHub Actions Failing**:
   - Verify AWS_ROLE_ARN secret
   - Check IAM role trust policy
   - Validate OIDC provider setup

3. **High Error Rates**:
   - Check application logs in CloudWatch
   - Verify database connections
   - Review resource limits

### Debugging Commands:
```bash
# Check ECS service status
aws ecs describe-services --cluster auto-pipe-cluster --services auto-pipe-service

# View container logs
aws logs tail /ecs/auto-pipe-app --follow

# Test health endpoint
curl https://your-alb-endpoint/health
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions or issues:
- Create an issue in this repository
- Check the troubleshooting section
- Review AWS CloudWatch logs
- Contact the development team

---

**Built with ❤️ for demonstrating modern DevOps practices**
