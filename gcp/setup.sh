#!/bin/bash

# GCP Setup Script for CI/CD POC
# This script sets up the necessary GCP resources for the CI/CD pipeline

set -e

# Configuration
PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"us-central1"}
CLUSTER_NAME=${3:-"cicd-poc-cluster"}
GAR_REPOSITORY=${4:-"cicd-poc-app"}

echo "Setting up GCP resources for CI/CD POC..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Cluster Name: $CLUSTER_NAME"
echo "GAR Repository: $GAR_REPOSITORY"

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containeranalysis.googleapis.com

# Create Artifact Registry repository
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create $GAR_REPOSITORY \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for CI/CD POC app"

# Create GKE cluster
echo "Creating GKE cluster..."
gcloud container clusters create $CLUSTER_NAME \
    --region=$REGION \
    --num-nodes=3 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --machine-type=e2-medium \
    --enable-autorepair \
    --enable-autoupgrade \
    --enable-ip-alias \
    --network=default \
    --subnetwork=default

# Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION

# Create a static IP for the ingress
echo "Creating static IP..."
gcloud compute addresses create cicd-poc-ip --global

# Create managed SSL certificate
echo "Creating managed SSL certificate..."
kubectl apply -f - <<EOF
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: cicd-poc-ssl-cert
  namespace: cicd-poc
spec:
  domains:
    - cicd-poc.yourdomain.com
EOF

echo "GCP setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Update the domain in k8s/ingress.yaml and gcp/setup.sh"
echo "2. Configure DNS to point to the static IP:"
echo "   gcloud compute addresses describe cicd-poc-ip --global"
echo "3. Set up GitHub secrets:"
echo "   - GCP_PROJECT_ID: $PROJECT_ID"
echo "   - GCP_SA_KEY: (service account key JSON)"
echo "4. Create a service account with necessary permissions"
