# Auto-Pipe

Automated deployment pipeline for a FastAPI application using Docker, GitHub Actions, and AWS ECS.

## Overview

This project demonstrates a complete CI/CD pipeline that:
- Builds and tests a FastAPI application
- Creates Docker images with security best practices
- Deploys to AWS ECS Fargate using GitHub Actions
- Monitors applications with CloudWatch
- Sends notifications to Slack

## Tech Stack

- **Backend**: FastAPI, Python 3.11
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions with OIDC authentication
- **Cloud**: AWS ECS Fargate, ECR, CloudWatch
- **Monitoring**: CloudWatch Alarms, SNS, Slack integration

## Local Development

```bash
# Clone and setup
git clone https://github.com/cyno-benzene/auto-pipe.git
cd auto-pipe

# Run with Docker Compose
docker compose up --build

# Or run locally
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest tests/
uvicorn app.main:app --reload
```

API will be available at http://localhost:8000

## API Endpoints

- `GET /health` - Health check
- `GET /items/{id}` - Get item by ID
- `POST /items` - Create item
- `GET /docs` - Interactive API docs

## AWS Deployment

### Prerequisites
- AWS CLI configured
- GitHub repository with OIDC setup

### Setup Infrastructure
```bash
cd infrastructure
./setup.sh
```

### GitHub Secrets Required
- `AWS_ROLE_ARN`: IAM role for deployments
- `SLACK_WEBHOOK_URL`: Slack notifications

## Project Structure

```
├── app/                    # FastAPI application
├── tests/                  # Unit tests
├── infrastructure/         # AWS setup scripts
├── .github/workflows/      # CI/CD pipeline
├── Dockerfile             # Container definition
└── taskdef.template.json  # ECS task definition
```

## Features

### Security
- OIDC authentication (no stored AWS credentials)
- Non-root container user
- ECR image vulnerability scanning
- Least privilege IAM policies

### Monitoring
- CloudWatch logs and metrics
- Custom application alarms
- Slack notifications for deployments and alerts
- Health check endpoints

### CI/CD Pipeline
1. **Test**: Run unit tests and linting
2. **Build**: Create and push Docker image to ECR
3. **Deploy**: Update ECS service with new task definition
4. **Notify**: Send deployment status to Slack

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and add tests
4. Submit a pull request

## License

MIT
