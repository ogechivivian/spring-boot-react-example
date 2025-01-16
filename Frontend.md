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
Copy code
git add frontend/
git commit -m "Update frontend application"
git push origin main
```
## Monitor the Workflow:

Go to the Actions tab in your GitHub repository to monitor the build and deployment process.

Access Your Application:

Once deployed, your frontend application will be accessible via the Nginx service's external IP or domain configured in your Kubernetes manifests
# Usage
## Building Locally
If you want to build and run the Docker image locally:

## Navigate to Frontend Directory:

```bash
Copy code
cd frontend
Build the Docker Image:
```
```bash
Copy code
docker build -t my-frontend:latest .
Run the Docker Container:
```
```bash
Copy code
docker run -p 8080:8080 my-frontend:latest
```
Access the application at http://localhost:8080.