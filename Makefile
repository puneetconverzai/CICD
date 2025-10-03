# Makefile for CI/CD POC

.PHONY: help build test run clean docker-build docker-run k8s-apply k8s-delete gcp-setup gcp-cleanup

# Default target
help:
	@echo "Available targets:"
	@echo "  build        - Build the .NET application"
	@echo "  test         - Run tests"
	@echo "  run          - Run the application locally"
	@echo "  clean        - Clean build artifacts"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run   - Run Docker container"
	@echo "  k8s-apply    - Apply Kubernetes manifests"
	@echo "  k8s-delete   - Delete Kubernetes resources"
	@echo "  gcp-setup    - Setup GCP resources"
	@echo "  gcp-cleanup  - Cleanup GCP resources"

# .NET targets
build:
	dotnet build

test:
	dotnet test

run:
	dotnet run

clean:
	dotnet clean
	rm -rf bin/ obj/

# Docker targets
docker-build:
	docker build -t cicd-poc-app .

docker-run:
	docker run -p 8080:8080 cicd-poc-app

# Kubernetes targets
k8s-apply:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete -f k8s/

# GCP targets
gcp-setup:
	@echo "Please run: ./gcp/setup.sh YOUR_PROJECT_ID"

gcp-cleanup:
	@echo "Please run: ./gcp/cleanup.sh YOUR_PROJECT_ID"

# Development targets
dev: build run

docker-dev: docker-build docker-run

# All-in-one targets
setup: gcp-setup k8s-apply

teardown: k8s-delete gcp-cleanup
