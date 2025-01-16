# Frontend Project Documentation

## Project Structure

```plaintext
.
├── Dockerfile
├── frontend
│   ├── package.json
│   ├── package-lock.json
│   ├── src
│   │   └── ... (React source files)
│   └── webpack.config.js
├── k8s
│   └── Development
│       ├── frontend-deployment.yaml
│       ├── frontend-service.yaml
│       └── frontend-hpa.yaml
├── .github
│   └── workflows
│       └── frontend.yml
└── README.md
```

# Frontend Project Documentation

## Environment Variables and Secrets

To ensure secure and flexible deployments, the workflow utilizes **GitHub Secrets**. Configure these secrets in your repository settings under **Settings > Secrets and variables > Actions**.

### Required Secrets

#### Docker Hub Credentials

- **DOCKER_USERNAME**: Your Docker Hub username.
- **DOCKER_PASSWORD**: Your Docker Hub password or access token.

#### AWS Credentials

- **AWS_ACCESS_KEY_ID**: Your AWS access key ID.
- **AWS_SECRET_ACCESS_KEY**: Your AWS secret access key.
- **AWS_REGION**: AWS region where your EKS cluster is hosted (e.g., `us-west-2`).
- **EKS_CLUSTER_NAME**: The name of your EKS cluster.

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```
## Configure GitHub Secrets:

Navigate to your repository on GitHub and add the required secrets under Settings > Secrets and variables > Actions.

## Push Changes to Frontend Directory:

Any push to the frontend/** path will trigger the GitHub Actions workflow.

```bash
git add frontend/
git commit -m "Update frontend application"
git push origin main
```
## Monitor the Workflow:

Go to the Actions tab in your GitHub repository to monitor the build and deployment process.

## Access Your Application:

Once deployed, your frontend application will be accessible via the Nginx service's external IP or domain configured in your Kubernetes manifests
# Usage
## Building Locally
If you want to build and run the Docker image locally:

## Navigate to Frontend Directory:

```bash
cd frontend
```
## Build the Docker Image:
```bash
docker build -t my-frontend:latest .
```
## Run the Docker Container:

```bash
docker run -p 8080:8080 my-frontend:latest
```
Access the application at http://localhost:8080.

## Pushing Changes
This will trigger the GitHub Actions workflow to build and deploy your changes.
```bash
git add frontend/
git commit -m "Your commit message"
git push origin main
```

# Backend Project Documentation

Welcome to the **Backend CI/CD** project! This repository provides a streamlined setup for building a Spring Boot-based backend application using Java and Docker, and automating the deployment process to AWS Elastic Kubernetes Service (EKS) using GitHub Actions.

## Features

- **Maven Build**: Efficiently build Java applications using Maven.
- **Dockerization**: Containerize the backend application for consistent deployments.
- **Automated CI/CD Pipeline**: Build, test, Dockerize, push, and deploy using GitHub Actions.
- **AWS EKS Integration**: Seamlessly deploy to Kubernetes clusters.
- **Horizontal Pod Autoscaling (HPA)**: Ensure scalability based on demand.

## Prerequisites

Before getting started, ensure you have the following:

- **Java Development Kit (JDK)**: Version 17.x
- **Maven**: Installed and configured
- **Docker**: Installed and configured
- **GitHub Account**: With repository access
- **AWS Account**: Access to EKS and necessary permissions
- **AWS CLI**: Installed and configured
- **kubectl**: Installed for Kubernetes interactions

## Project Structure

```plaintext
.
├── Dockerfile
├── backend
│   ├── pom.xml
│   ├── src
│   │   └── ... (Java source files)
├── k8s
│   └── Development
│       ├── backend-deployment.yaml
│       ├── backend-service.yaml
│       └── backend-hpa.yaml
├── .github
│   └── workflows
│       └── backend.yml
└── README.md
```
## GitHub Actions Workflow
The workflow is defined in .github/workflows/backend.yml.

## Environment Variables and Secrets
This is same as the frontend above.

## Deployment Steps
###  Clone the Repository
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo

```
## Configure GitHub Secrets
Navigate to your repository on GitHub and add the required secrets under Settings > Secrets and variables > Actions.
## Push Changes to Backend Directory
   Any push to the backend/** path will trigger the GitHub Actions workflow.
```bash
git add backend/
git commit -m "Update backend application"
git push origin main

```

## Monitor the Workflow
Go to the Actions tab in your GitHub repository to monitor the build and deployment process.

## Access Your Application
   Once deployed, your backend application will be accessible via the service's external IP or domain configured in your Kubernetes manifests.

# Usage
## Building Locally
If you want to build and run the Docker image locally, follow these steps:
## Navigate to Backend Directory

```bash 
cd backend
docker build -t my-backend:latest .
docker run -p 8080:8080 my-backend:latest
```
Access the application at http://localhost:8080.
# Terraform CI/CD User Guide

Welcome to the **Terraform CI/CD** user guide! This documentation provides a comprehensive overview of the Terraform Continuous Integration and Continuous Deployment (CI/CD) setup using GitHub Actions. 
The workflow automates the process of formatting, validating, planning, and applying Terraform configurations, ensuring consistent and reliable infrastructure deployments.


# Usage
## Creating a Pull Request
### Create a New Branch:

```bash
git checkout -b feature/add-new-resource
```
### Make Changes: 
Update or add Terraform configuration files in the terraform/ directory.

### Commit Changes:

```bash
git add terraform/
git commit -m "Add new AWS EC2 instance configuration"
```
### Push to GitHub:

```bash
git push origin feature/add-new-resource
```
### Open a Pull Request:

- Navigate to your repository on GitHub.
- Click on Compare & pull request.
- Review the changes and submit the pull request.
### Review Workflow Comments:

- The Terraform workflow will comment on the pull request with the results.
- Review the Terraform plan output to understand the proposed changes.
### Address Any Issues:

- If the workflow detects formatting or validation issues, address them and push the changes to the branch.
- The workflow will re-run automatically with each push.
### Merge the Pull Request:

- Once all checks pass, merge the pull request into the master branch.
- This will trigger the Terraform apply step to deploy the changes.
## Merging to Master
Merging changes to the master branch triggers the Terraform apply step, which automatically applies the infrastructure changes defined in your Terraform configurations.

```bash
git checkout master
git merge feature/add-new-resource
git push origin master
```
## Monitoring and Logs
To monitor the progress and view logs of the Terraform workflow:

### Navigate to Actions Tab:

- Go to your GitHub repository.
- Click on the Actions tab.
### Select Workflow Run:

- Click on the specific workflow run you want to inspect.
- You can view detailed logs for each step by expanding them.
### Review Pull Request Comments:

- For pull requests, the workflow results are posted as comments.
- These comments provide a summary of the Terraform workflow, including formatting, validation, and plan outcomes.


## License
This project is licensed under the MIT License.