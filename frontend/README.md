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

## GitHub Actions Workflow: Build and Deploy Frontend

This workflow automates building a React-based frontend application, creating a Docker image, pushing it to Docker Hub, and deploying it to an Amazon EKS cluster.

### Trigger
The workflow is triggered by any push to the `frontend/**` path:

```yaml
on:
  push:
    paths:
      - "frontend/**"
```

### Jobs

#### Build and Push Docker Image

This job builds the Docker image for the React app and pushes it to Docker Hub.

**Steps:**
1. **Checkout Code**: Fetch the repository's code.
   ```yaml
   - name: Checkout Code
     uses: actions/checkout@v3
   ```

2. **Set up Node.js**: Install Node.js version 18.
   ```yaml
   - name: Set up Node.js
     uses: actions/setup-node@v3
     with:
       node-version: 18
   ```

3. **Build React App**: Install dependencies and build the React app.
   ```yaml
   - name: Build React App
     run: |
       cd frontend
       npm install
       export NODE_OPTIONS=--openssl-legacy-provider
       npm run build
   ```

4. **Log in to Docker Hub**: Authenticate with Docker Hub.
   ```yaml
   - name: Log in to Docker Hub
     run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
   ```

5. **Build Docker Image**: Create the Docker image.
   ```yaml
   - name: Build Docker Image
     run: |
       docker build -t my-frontend:latest ./frontend
       docker tag my-frontend:latest docker.io/${{ secrets.DOCKER_USERNAME }}/my-frontend:latest
       docker tag my-frontend:latest docker.io/${{ secrets.DOCKER_USERNAME }}/my-frontend:${{ github.sha }}
   ```

6. **Push Docker Image**: Push the image to Docker Hub.
   ```yaml
   - name: Push Docker Image
     run: |
       docker push docker.io/${{ secrets.DOCKER_USERNAME }}/my-frontend:latest
       docker push docker.io/${{ secrets.DOCKER_USERNAME }}/my-frontend:${{ github.sha }}
   ```

#### Deploy to EKS

This job deploys the built Docker image to an Amazon EKS cluster.

**Steps:**

1. **Checkout Code**: Fetch the repository's code.
   ```yaml
   - name: Checkout Code
     uses: actions/checkout@v3
   ```

2. **Configure AWS Credentials**: Set up AWS CLI credentials.
   ```yaml
   - name: Configure AWS Credentials
     uses: aws-actions/configure-aws-credentials@v2
     with:
       aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
       aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
       aws-region: ${{ secrets.AWS_REGION }}
   ```

3. **Install `kubectl`**: Install the Kubernetes CLI tool.
   ```yaml
   - name: Install kubectl
     run: |
       curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
       chmod +x kubectl
       sudo mv kubectl /usr/local/bin/
   ```

4. **Update `kubeconfig`**: Configure access to the EKS cluster.
   ```yaml
   - name: Update kubeconfig
     run: |
       aws eks update-kubeconfig --region ${{ secrets.AWS_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}
   ```

5. **Deploy to EKS**: Apply Kubernetes manifests and update the deployment's image.
   ```yaml
   - name: Deploy to EKS
     run: |
       IMAGE_TAG=${{ github.sha }}
       kubectl apply -f k8s/Development/frontend-deployment.yaml
       kubectl apply -f k8s/Development/frontend-service.yaml
       kubectl apply -f k8s/Development/frontend-hpa.yaml
       kubectl set image deployment/frontend-deployment frontend=docker.io/${{ secrets.DOCKER_USERNAME }}/my-frontend:${IMAGE_TAG}
       kubectl rollout status deployment/frontend-deployment
   ```

6. **Apply HPA**: Deploy Horizontal Pod Autoscaler configurations.
   ```yaml
   - name: Apply HPA for Frontend
     run: |
       kubectl apply -f k8s/Development/frontend-hpa.yaml
   ```

## Dockerfile

### Build Stage

This stage builds the React application:

```dockerfile
# Build with Node
FROM node:18 AS build

# Needed for Node+OpenSSL issues
ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /app

# Copying the package.json + lock files
COPY package*.json ./
RUN npm install

# Copying the source (including webpack.config.js)
COPY src ./src
COPY webpack.config.js ./

# Run the build
RUN npm run build
```

### Runtime Stage

This stage serves the built application using Nginx:

```dockerfile
# Serving with Nginx
FROM nginx:alpine

# Copy final compiled files from build stage
COPY --from=build /app/target/classes/static/built /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
```

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

### 2. Configure GitHub Secrets

Navigate to your repository on GitHub and add the required secrets under **Settings > Secrets and variables > Actions**.

### 3. Push Changes to Frontend Directory

Any push to the `frontend/**` path will trigger the GitHub Actions workflow.

```bash
git add frontend/
git commit -m "Update frontend application"
git push origin main
```

### 4. Monitor the Workflow

Go to the **Actions tab** in your GitHub repository to monitor the build and deployment process.

### 5. Access Your Application

Once deployed, your frontend application will be accessible via the Nginx service's external IP or domain configured in your Kubernetes manifests.

## Usage

### Building Locally

If you want to build and run the Docker image locally:

#### Navigate to Frontend Directory

```bash
cd frontend
```

#### Build the Docker Image

```bash
docker build -t my-frontend:latest .
```

#### Run the Docker Container

```bash
docker run -p 8080:8080 my-frontend:latest
```

Access the application at http://localhost:8080.

### Pushing Changes

Any push made to the `frontend` directory will trigger the GitHub Actions workflow to build and deploy your changes.

```bash
git add frontend/
git commit -m "Your commit message"
git push origin main
```

