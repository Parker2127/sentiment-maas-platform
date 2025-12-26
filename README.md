
# Sentiment Analysis MaaS Platform

This is a Model as a Service platform for sentiment analysis using FastAPI and Hugging Face transformers.

## Features

- RESTful API for sentiment analysis
- Docker containerized
- Terraform for infrastructure as code
- CI/CD with GitHub Actions

## Local Development

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the application:
   ```bash
   uvicorn app.main:app --reload
   ```

3. Test the API:
   ```bash
   curl -X POST "http://localhost:8000/analyze" -H "Content-Type: application/json" -d '{"text": "I love this!"}'
   ```

## API Documentation

- **Endpoint**: `POST /analyze`
- **Request Body**:
  ```json
  {
    "text": "string"
  }
  ```
- **Response**:
  ```json
  {
    "sentiment": "POSITIVE" | "NEGATIVE",
    "confidence": 0.0-1.0
  }
  ```

## Deployment

### Docker

Build and run the Docker container:
```bash
docker build -t sentiment-maas .
docker run -p 8000:8000 sentiment-maas
```

### Terraform

Navigate to the `terraform/` directory and run:
```bash
terraform init
terraform plan
terraform apply
```

This will create:
- Azure Resource Group
- Azure Container Registry (ACR)
- Azure App Service with staging and production deployment slots
- Azure Monitor alert for confidence score metrics

### CI/CD

The GitHub Actions workflow in `.github/workflows/deploy.yml` will automatically:
1. Build and push the Docker image to Azure Container Registry
2. Deploy to the staging slot
3. Run tests on staging
4. Swap to production slot

## Infrastructure Components

### Azure Resources Created
- **Resource Group**: Contains all resources
- **Container Registry**: Stores Docker images
- **App Service**: Hosts the web application with deployment slots
- **Application Insights**: Monitors application performance
- **Monitor Alert**: Triggers when sentiment confidence drops below 0.6

### Environment Variables Required
For GitHub Actions deployment, set these secrets:
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `ACR_USERNAME`: Container registry username
- `ACR_PASSWORD`: Container registry password
- `AZURE_APP_NAME`: App Service name