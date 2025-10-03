#!/bin/bash

# GCP Cleanup Script for CI/CD POC
# This script removes all GCP resources created for the CI/CD POC

set -e

# Configuration
PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"us-central1"}
CLUSTER_NAME=${3:-"cicd-poc-cluster"}
GAR_REPOSITORY=${4:-"cicd-poc-app"}
SERVICE_ACCOUNT_NAME=${5:-"github-actions-cicd"}

echo "Cleaning up GCP resources for CI/CD POC..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Cluster Name: $CLUSTER_NAME"
echo "GAR Repository: $GAR_REPOSITORY"
echo "Service Account: $SERVICE_ACCOUNT_NAME"

# Set the project
gcloud config set project $PROJECT_ID

# Delete GKE cluster
echo "Deleting GKE cluster..."
gcloud container clusters delete $CLUSTER_NAME --region=$REGION --quiet

# Delete Artifact Registry repository
echo "Deleting Artifact Registry repository..."
gcloud artifacts repositories delete $GAR_REPOSITORY --location=$REGION --quiet

# Delete static IP
echo "Deleting static IP..."
gcloud compute addresses delete cicd-poc-ip --global --quiet

# Delete service account
echo "Deleting service account..."
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
gcloud iam service-accounts delete $SERVICE_ACCOUNT_EMAIL --quiet

echo "GCP cleanup completed successfully!"
echo ""
echo "All resources have been removed:"
echo "- GKE cluster: $CLUSTER_NAME"
echo "- Artifact Registry repository: $GAR_REPOSITORY"
echo "- Static IP: cicd-poc-ip"
echo "- Service account: $SERVICE_ACCOUNT_EMAIL"
