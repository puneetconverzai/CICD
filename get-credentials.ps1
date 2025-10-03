# PowerShell script to get your personal account credentials for GitHub Actions
# Run this script to get the credentials you need

Write-Host "Getting your personal account credentials..." -ForegroundColor Green

# Get your account info
$account = gcloud auth list --format="value(account)" --filter="status:ACTIVE"
Write-Host "Account: $account" -ForegroundColor Yellow

# Get access token
Write-Host "Getting access token..." -ForegroundColor Green
$accessToken = gcloud auth print-access-token
Write-Host "Access Token: $accessToken" -ForegroundColor Yellow

# Get project info
$project = gcloud config get-value project
Write-Host "Project: $project" -ForegroundColor Yellow

Write-Host "`nTo use these credentials in GitHub Actions:" -ForegroundColor Green
Write-Host "1. Go to your GitHub repository" -ForegroundColor White
Write-Host "2. Go to Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "3. Add these secrets:" -ForegroundColor White
Write-Host "   - GCP_ACCESS_TOKEN: $accessToken" -ForegroundColor Cyan
Write-Host "   - GCP_PROJECT_ID: $project" -ForegroundColor Cyan

Write-Host "`nNote: Access tokens expire, so you'll need to update them periodically." -ForegroundColor Red
Write-Host "For production use, consider using Workload Identity or Service Account keys." -ForegroundColor Red
