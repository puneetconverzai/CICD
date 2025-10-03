#!/bin/bash

# Service Account Setup Script for CI/CD POC
# This script creates a service account with necessary permissions for GitHub Actions

set -e

# Configuration
PROJECT_ID=${1:-"your-project-id"}
SERVICE_ACCOUNT_NAME=${2:-"github-actions-cicd"}
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "Creating service account for GitHub Actions..."
echo "Project ID: $PROJECT_ID"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"

# Create service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions CI/CD" \
    --description="Service account for GitHub Actions CI/CD pipeline"

# Assign necessary roles
echo "Assigning IAM roles..."

# Artifact Registry roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/artifactregistry.reader"

# GKE roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/container.developer"

# Cloud Build roles (if using Cloud Build)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/cloudbuild.builds.builder"

# Storage roles (for any storage needs)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

# Compute roles (for managing compute resources)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.viewer"

# Create and download service account key
echo "Creating service account key..."
gcloud iam service-accounts keys create github-actions-key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "Service account setup completed!"
echo ""
echo "Service Account Email: $SERVICE_ACCOUNT_EMAIL"
echo "Key file created: github-actions-key.json"
echo ""
echo "Next steps:"
echo "1. Add the contents of github-actions-key.json as GCP_SA_KEY secret in GitHub"
echo "2. Delete the key file from your local machine for security:"
echo "   rm github-actions-key.json"
echo "3. The service account has the following permissions:"
echo "   - Artifact Registry Writer/Reader"
echo "   - Container Developer"
echo "   - Cloud Build Builder"
echo "   - Storage Admin"
echo "   - Compute Viewer"
