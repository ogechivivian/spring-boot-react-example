## Backend Project Documentation

### Project Structure

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

### GitHub Actions Workflow: Build and Deploy Backend

This workflow automates building a Spring Boot-based backend application, creating a Docker image, pushing it to Docker Hub, and deploying it to an Amazon EKS cluster.

**Trigger:** The workflow is triggered by any push to the `backend/**` path:

```yaml
on:
  push:
    paths:
      - "backend/**"
```

### Dockerfile

#### Build Stage

```dockerfile
# Build Stage: Use Maven to build the backend
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests
```

#### Runtime Stage

```dockerfile
# Runtime Stage: Use a lightweight JDK to run the app
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Jobs

#### Build and Push Docker Image

This job builds the Docker image for the Spring Boot app and pushes it to Docker Hub.

**Steps:**
1. Checkout code and set up Java.
2. Build the application using Maven.
3. Test the application.
4. Create and push a Docker image.

```yaml
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build Backend
        run: |
          cd backend
          mvn clean package -DskipTests

      - name: Test Backend
        run: |
          cd backend
          mvn test

      - name: Docker Build
        run: |
          docker build -t my-backend:latest ./backend

      - name: Docker Push
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker tag my-backend:latest docker.io/${{ secrets.DOCKER_USERNAME }}/my-backend:latest
          docker push docker.io/${{ secrets.DOCKER_USERNAME }}/my-backend:latest
```

#### Deploy to EKS

This job deploys the built Docker image to an Amazon EKS cluster.

**Steps:**
1. Configure AWS credentials.
2. Install and configure `kubectl`.
3. Deploy Kubernetes manifests and update the image.
4. Apply HPA configurations.

```yaml
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Install kubectl
        run: |
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --region ${{ secrets.AWS_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}

      - name: Deploy to EKS
        run: |
          kubectl apply -f k8s/Development/backend-deployment.yaml
          kubectl apply -f k8s/Development/backend-service.yaml
          kubectl apply -f k8s/Development/backend-hpa.yaml
          IMAGE_TAG=${{ github.sha }}
          kubectl set image deployment/backend-deployment backend=docker.io/${{ secrets.DOCKER_USERNAME }}/my-backend:${IMAGE_TAG}
          kubectl rollout status deployment/backend-deployment

      - name: Apply HPA for Backend
        run: |
          kubectl apply -f k8s/Development/backend-hpa.yaml
```

### Deployment Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

2. **Configure GitHub Secrets**
   Add the following secrets in your GitHub repository settings:

    - **DOCKER_USERNAME**
    - **DOCKER_PASSWORD**
    - **AWS_ACCESS_KEY_ID**
    - **AWS_SECRET_ACCESS_KEY**
    - **AWS_REGION**
    - **EKS_CLUSTER_NAME**

3. **Push Changes to Backend Directory**
   Any push to the `backend/**` path will trigger the GitHub Actions workflow.

   ```bash
   git add backend/
   git commit -m "Update backend application"
   git push origin main
   ```

4. **Monitor the Workflow**
   Monitor the build and deployment process in the **Actions tab** of your GitHub repository.

5. **Access Your Application**
   The backend application will be accessible via the service's external IP or configured domain in your Kubernetes cluster.

### Building Locally

If you want to build and run the Docker image locally:

```bash
cd backend
mvn clean package

docker build -t my-backend:latest .
docker run -p 8080:8080 my-backend:latest
```

Access the application at http://localhost:8080.

