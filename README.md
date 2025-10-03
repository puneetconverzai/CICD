# CI/CD POC with GitHub Actions and GCP Kubernetes

This is a Proof of Concept (POC) project demonstrating a complete CI/CD pipeline using GitHub Actions, Docker, and Google Cloud Platform (GCP) with Kubernetes. The project includes a .NET 8 Web API application that gets automatically built, tested, containerized, and deployed to GCP Kubernetes Engine (GKE).

## 🏗️ Architecture

```
GitHub Repository
    ↓ (Push to main branch)
GitHub Actions CI/CD Pipeline
    ↓ (Build & Test)
Docker Image
    ↓ (Push to GCP Artifact Registry)
Google Kubernetes Engine (GKE)
    ↓ (Deploy)
Load Balancer → Application
```

## 📋 Prerequisites

- GitHub account with repository access
- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and configured
- `kubectl` CLI installed
- Docker installed (for local development)

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd CICD
```

### 2. GCP Setup

#### Option A: Automated Setup (Recommended)

```bash
# Make scripts executable
chmod +x gcp/*.sh

# Run the setup script
./gcp/setup.sh YOUR_PROJECT_ID us-central1 cicd-poc-cluster cicd-poc-app
```

#### Option B: Manual Setup

1. **Enable Required APIs:**
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   ```

2. **Create Artifact Registry:**
   ```bash
   gcloud artifacts repositories create cicd-poc-app \
       --repository-format=docker \
       --location=us-central1
   ```

3. **Create GKE Cluster:**
   ```bash
   gcloud container clusters create cicd-poc-cluster \
       --region=us-central1 \
       --num-nodes=3 \
       --enable-autoscaling \
       --min-nodes=1 \
       --max-nodes=10
   ```

### 3. Service Account Setup

```bash
# Create service account for GitHub Actions
./gcp/service-account-setup.sh YOUR_PROJECT_ID github-actions-cicd

# This creates a key file: github-actions-key.json
```

### 4. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_SA_KEY`: Contents of the `github-actions-key.json` file

### 5. Update Configuration

1. **Update the domain in ingress:**
   ```bash
   # Edit k8s/ingress.yaml
   # Replace 'cicd-poc.yourdomain.com' with your actual domain
   ```

2. **Update PROJECT_ID in deployment:**
   ```bash
   # The GitHub Actions workflow will automatically update this
   # But you can manually update k8s/deployment.yaml if needed
   ```

### 6. Deploy

Push to the main branch to trigger the CI/CD pipeline:

```bash
git add .
git commit -m "Initial CI/CD setup"
git push origin main
```

## 📁 Project Structure

```
CICD/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # GitHub Actions workflow
├── Controllers/
│   ├── WeatherController.cs       # Sample API controller
│   └── HealthController.cs        # Health check controller
├── k8s/
│   ├── namespace.yaml             # Kubernetes namespace
│   ├── deployment.yaml            # Application deployment
│   ├── service.yaml               # Load balancer service
│   ├── ingress.yaml               # Ingress configuration
│   └── hpa.yaml                   # Horizontal Pod Autoscaler
├── gcp/
│   ├── setup.sh                   # GCP resource setup
│   ├── service-account-setup.sh   # Service account creation
│   └── cleanup.sh                 # Resource cleanup
├── CicdPocApp.csproj              # .NET project file
├── Program.cs                      # Application entry point
├── Dockerfile                      # Docker configuration
├── .dockerignore                   # Docker ignore file
└── README.md                       # This file
```

## 🔧 Application Features

### API Endpoints

- `GET /` - Root endpoint with basic info
- `GET /api/weather` - Sample weather forecast API
- `GET /api/weather/{id}` - Get specific weather forecast
- `GET /api/health` - Health check endpoint
- `GET /health/ready` - Kubernetes readiness probe
- `GET /health/live` - Kubernetes liveness probe

### Health Checks

The application includes comprehensive health checks for Kubernetes:
- **Readiness Probe**: `/health/ready` - Used to determine if the pod is ready to receive traffic
- **Liveness Probe**: `/health/live` - Used to determine if the pod is alive and should be restarted

## 🚀 CI/CD Pipeline

The GitHub Actions workflow includes:

### 1. Test Job
- Code checkout
- .NET 8 setup
- Dependency restoration
- Build verification
- Unit tests execution
- Code linting

### 2. Build and Push Job (main branch only)
- Docker image building
- Image tagging with commit SHA and latest
- Push to GCP Artifact Registry
- Kubernetes manifest updates
- GKE deployment
- Deployment verification

### 3. Security Scan Job
- Trivy vulnerability scanning
- SARIF report upload to GitHub Security tab

## 🐳 Docker Configuration

The application uses a multi-stage Docker build:
- **Build stage**: Uses .NET 8 SDK to build the application
- **Runtime stage**: Uses .NET 8 runtime for production
- **Security**: Runs as non-root user (appuser)
- **Port**: Exposes port 8080

## ☸️ Kubernetes Configuration

### Resources
- **Namespace**: `cicd-poc`
- **Deployment**: 3 replicas with auto-scaling (2-10 pods)
- **Service**: LoadBalancer type for external access
- **Ingress**: GCP load balancer with SSL termination
- **HPA**: CPU and memory-based auto-scaling

### Security
- Non-root container execution
- Security context with dropped capabilities
- Resource limits and requests

## 🔍 Monitoring and Observability

### Health Checks
- Application-level health checks
- Kubernetes-native probes
- Detailed health status reporting

### Logging
- Structured logging with .NET ILogger
- Request/response logging
- Error tracking

### Metrics
- Kubernetes resource metrics
- Application performance metrics
- Auto-scaling based on CPU/memory usage

## 🧪 Testing

### Local Testing

```bash
# Run the application locally
dotnet run

# Run tests
dotnet test

# Build Docker image locally
docker build -t cicd-poc-app .
docker run -p 8080:8080 cicd-poc-app
```

### API Testing

```bash
# Test the API endpoints
curl http://localhost:8080/
curl http://localhost:8080/api/weather
curl http://localhost:8080/api/health
```

## 🔧 Configuration

### Environment Variables
- `ASPNETCORE_ENVIRONMENT`: Environment (Development/Production)
- `ASPNETCORE_URLS`: Application URLs

### Kubernetes Configuration
- Resource requests and limits
- Health check intervals
- Security contexts
- Auto-scaling parameters

## 🛠️ Troubleshooting

### Common Issues

1. **Build Failures**
   - Check .NET version compatibility
   - Verify all dependencies are restored
   - Review build logs in GitHub Actions

2. **Deployment Issues**
   - Verify GCP credentials
   - Check cluster connectivity
   - Review Kubernetes logs: `kubectl logs -n cicd-poc deployment/cicd-poc-app`

3. **Image Push Failures**
   - Verify Artifact Registry permissions
   - Check service account key
   - Ensure repository exists

### Useful Commands

```bash
# Check cluster status
kubectl get nodes

# Check application pods
kubectl get pods -n cicd-poc

# Check service
kubectl get service -n cicd-poc

# View application logs
kubectl logs -n cicd-poc deployment/cicd-poc-app -f

# Check ingress
kubectl get ingress -n cicd-poc

# Scale deployment
kubectl scale deployment cicd-poc-app -n cicd-poc --replicas=5
```

## 🧹 Cleanup

To remove all GCP resources:

```bash
./gcp/cleanup.sh YOUR_PROJECT_ID us-central1 cicd-poc-cluster cicd-poc-app github-actions-cicd
```

## 📚 Additional Resources

- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Check Kubernetes logs
4. Create an issue in the repository

---

**Note**: This is a POC project. For production use, consider additional security measures, monitoring, and operational practices.
