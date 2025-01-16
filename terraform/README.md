# Terraform GitHub Actions Workflow

This README outlines the Terraform workflows set up for automated infrastructure management using GitHub Actions. These workflows are designed for provisioning and destroying Terraform-managed infrastructure. Below is an explanation of the workflows and their components.

---

## **Workflows**

### 1. **Terraform Provisioning Workflow**
This workflow runs on pushes and pull requests to the `master` branch for files in the `terraform/` directory. It automates Terraform formatting checks, initialization, validation, planning, and applying.

#### **Trigger**
- **Push**: On push to the `master` branch.
- **Pull Request**: On pull requests targeting the `master` branch.

#### **Job: terraform**
Runs the Terraform steps sequentially:
1. **Checkout Repository**:
    - Uses `actions/checkout@v3` to clone the repository.
2. **Setup Terraform**:
    - Configures Terraform version `1.4.2` using `hashicorp/setup-terraform@v1`.
3. **Terraform Format**:
    - Checks formatting compliance using `terraform fmt -check -recursive`.
4. **Configure AWS Credentials**:
    - Uses `aws-actions/configure-aws-credentials@v3` to configure AWS credentials for Terraform actions.
5. **Terraform Init**:
    - Initializes Terraform working directory (`terraform init`).
6. **Terraform Validate**:
    - Validates the configuration (`terraform validate -no-color`).
7. **Terraform Plan** *(Pull Requests Only)*:
    - Runs `terraform plan` and captures the output for review.
8. **Update Pull Request** *(Pull Requests Only)*:
    - Posts the results (format, init, validate, and plan outcomes) as a comment on the pull request.
9. **Terraform Apply** *(Push to `master` Only)*:
    - Applies the plan (`terraform apply -auto-approve`).

---

### 2. **Terraform Destroy Workflow**
This workflow is manually triggered or runs on pushes to the `main` branch for files in the `terraform/` directory. It automates the destruction of Terraform-managed infrastructure.

#### **Trigger**
- **Workflow Dispatch**: Can be manually triggered.
- **Push**: On push to the `main` branch.

#### **Job: terraform-destroy**
Performs the following steps:
1. **Checkout Repository**:
    - Uses `actions/checkout@v3` to clone the repository.
2. **Setup Terraform**:
    - Configures Terraform version `1.4.2` using `hashicorp/setup-terraform@v1`.
3. **Configure AWS Credentials**:
    - Configures AWS credentials using `aws-actions/configure-aws-credentials@v3`.
4. **Terraform Init**:
    - Initializes Terraform working directory (`terraform init`).
5. **Terraform Destroy Plan**:
    - Generates a destruction plan (`terraform plan -destroy -no-color -input=false`).
6. **Terraform Destroy**:
    - Executes the destruction of resources (`terraform destroy -auto-approve`).

---

## **Environment Configuration**
Ensure the following GitHub secrets are configured:
- **`AWS_ACCESS_KEY_ID`**: Your AWS access key ID.
- **`AWS_SECRET_ACCESS_KEY`**: Your AWS secret access key.
- **`GITHUB_TOKEN`**: Automatically provided by GitHub Actions for interacting with the GitHub API.

---

## **Key Features**
- **Automatic Formatting Checks**: Ensures Terraform files adhere to standardized formatting.
- **Validation**: Confirms the correctness of Terraform configurations before deployment.
- **Plan Review**: Outputs the Terraform plan as a comment on pull requests.
- **Secure Credential Management**: Uses GitHub Secrets to handle sensitive AWS credentials.
- **Automation**: Fully automates Terraform provisioning and destruction with minimal manual intervention.

---

## **Usage**
- **Provisioning**:
    - Push or create a pull request to the `master` branch with changes in the `terraform/` directory.
- **Destruction**:
    - Trigger the `Terraform Destroy` workflow manually via the Actions tab or push changes to the `main` branch.

---

Feel free to customize these workflows further based on your Terraform and infrastructure requirements!
