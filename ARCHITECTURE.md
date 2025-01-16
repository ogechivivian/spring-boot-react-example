# EKS Infrastructure Architecture Documentation

This documentation provides an overview of the Amazon EKS (Elastic Kubernetes Service) infrastructure defined using Terraform. The architecture includes a Virtual Private Cloud (VPC), an EKS cluster, managed node groups, IAM roles, and logging mechanisms for auditing and monitoring.

---

## **1. VPC Configuration**

The Virtual Private Cloud (VPC) serves as the network backbone for the EKS cluster.

### **VPC Details:**
- **CIDR Block:** `10.0.0.0/16`
- **Availability Zones:** First three availability zones in the region (filtered using `opt-in-not-required`).
- **Subnets:**
    - Private Subnets: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
    - Public Subnets: `10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24`
- **NAT Gateway:** Single NAT Gateway for internet access from private subnets.
- **DNS Hostnames:** Enabled for internal hostname resolution.

### **Subnet Tagging:**
- Public Subnets: `kubernetes.io/role/elb = 1` (used for external load balancers).
- Private Subnets: `kubernetes.io/role/internal-elb = 1` (used for internal load balancers).

---

## **2. EKS Cluster Setup**

The Amazon EKS cluster is the central component for running Kubernetes workloads.

### **Cluster Details:**
- **Cluster Name:** Defined dynamically via `var.cluster_name`.
- **Kubernetes Version:** `1.29`
- **Endpoint Access:** Public endpoint enabled for API server access.
- **IAM Permissions:** Admin permissions granted to the cluster creator.

### **Cluster Add-ons:**
- **Amazon EBS CSI Driver:**
    - Enables dynamic provisioning of EBS volumes for Kubernetes.
    - Managed via IRSA (IAM Role for Service Accounts) using a dedicated role.

---

## **3. Managed Node Groups**

EKS-managed node groups provide compute capacity for the Kubernetes cluster.

### **Node Group Configurations:**
1. **Node Group 1:**
    - Name: `node-group-1`
    - Instance Type: `t3.small`
    - Scaling:
        - Min: 1
        - Max: 3
        - Desired: 2
2. **Node Group 2:**
    - Name: `node-group-2`
    - Instance Type: `t3.small`
    - Scaling:
        - Min: 1
        - Max: 2
        - Desired: 1

### **Default Settings:**
- **AMI Type:** `AL2_x86_64` (Amazon Linux 2 optimized for EKS).

---

## **4. IAM Configuration**

IAM roles and policies ensure secure access to AWS services for the EKS cluster and its components.

### **EKS Cluster IAM Role:**
- **Role Name:** `eks-access-role`
- **Permissions:**
    - `AmazonEKSClusterPolicy`: Provides control plane permissions.
    - `CloudWatchLogsFullAccess`: Ensures logs can be sent to CloudWatch.

### **IAM for EBS CSI Driver:**
- **Role Name:** `AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}`
- **Policy Attached:** `AmazonEBSCSIDriverPolicy`
- **Mapped to Service Account:** `ebs-csi-controller-sa` in the `kube-system` namespace.

### **IAM Users:**
- Individual IAM users are created for access, and each user is attached to `AmazonEKSWorkerNodePolicy`.

---

## **5. Logging and Monitoring**

### **Logging:**
- **CloudWatch Logs:**
    - Log Group: `/aws/eks/cluster-logs/${module.eks.cluster_name}`
    - Retention Period: 1 day.
- **Log Types Enabled:**
    - API Server
    - Audit Logs
    - Authenticator Logs
    - Controller Manager Logs
    - Scheduler Logs

- **CloudTrail:**
    - Multi-region trail enabled for EKS audit events.
    - Logs stored in an S3 bucket with versioning and lifecycle rules.

### **Monitoring:**
- **Prometheus:**
    - Installed via Helm in the `monitoring` namespace.
    - Service account created for Prometheus.

---

## **6. Storage Integration**

### **Amazon EBS CSI Driver:**
- Enables Kubernetes to dynamically provision EBS volumes for persistent storage.
- Configured using the `aws-ebs-csi-driver` add-on.

---

## **7. Security Best Practices**
- **IRSA:** Securely assigns fine-grained permissions to Kubernetes service accounts.
- **Subnet Segregation:** Public and private subnets are used to control access.
- **IAM Policies:** Least privilege is applied for IAM roles and policies.

---

## **8. High-Level Architecture Diagram**

```
              +-----------------------------------------------+
              |                AWS Management Console         |
              +-----------------------------------------------+
                               |
                               v
          +------------------------------------------------------+
          |                     AWS VPC                          |
          |                                                      |
          |  CIDR: 10.0.0.0/16                                   |
          |                                                      |
          |  +---------------------------------------------+     |
          |  |              Public Subnets                |     |
          |  |  10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24     |     |
          |  |  Tagged: kubernetes.io/role/elb            |     |
          |  +---------------------------------------------+     |
          |                                                      |
          |  +---------------------------------------------+     |
          |  |              Private Subnets               |     |
          |  |  10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24     |     |
          |  |  Tagged: kubernetes.io/role/internal-elb   |     |
          |  +---------------------------------------------+     |
          |                                                      |
          +------------------------+-----------------------------+
                                   |
                                   v
          +-------------------------------------------+
          |              Amazon EKS Cluster           |
          |  - Kubernetes Version: 1.29              |
          |  - Public Endpoint: Enabled              |
          |  - Monitoring: Prometheus                |
          |  - Auditing: CloudTrail, CloudWatch       |
          +-------------------------------------------+
                                   |
                +------------------+------------------+
                |                                     |
  +--------------------------+          +--------------------------+
  |   Managed Node Group 1   |          |   Managed Node Group 2   |
  |  Instance Type: t3.small |          |  Instance Type: t3.small |
  |  Desired Size: 2         |          |  Desired Size: 1         |
  +--------------------------+          +--------------------------+
                                   |
                                   v
            +---------------------------------------+
            |       IAM Roles and Permissions       |
            |  - AmazonEKSClusterPolicy            |
            |  - CloudWatchLogsFullAccess          |
            |  - AmazonEBSCSIDriverPolicy          |
            +---------------------------------------+
```

---

## **Conclusion**

This Terraform configuration provides a robust and scalable EKS infrastructure:
- Highly available VPC with public and private subnets.
- Secure and scalable managed node groups.
- Integrated monitoring and auditing via CloudWatch, CloudTrail, and Prometheus.
- Dynamic storage provisioning with Amazon EBS CSI Driver.
- Role-based access control using IAM and Kubernetes RBAC.

# TODO: To Enhance Robustness

To further improve the architecture's robustness:

---

## 1. Integrate Prometheus with Alertmanager
- **Why:** Enables real-time alert notifications for cluster issues.
- **Action:** Deploy Alertmanager and configure it with email, Slack, or PagerDuty integration.

---

## 2. Use Custom IAM Policies
- **Why:** Replace broad policies (`CloudWatchLogsFullAccess`, `AmazonEKSClusterPolicy`) with custom least-privilege policies to improve security.
- **Action:** Define granular permissions for each IAM role.

---

## 3. Extend Log Retention
- **Why:** Extend CloudWatch Logs retention from 1 day to at least 30 days for better troubleshooting and compliance.
- **Action:** Update the log group configuration in Terraform.

---

## 4. Deploy Kubernetes Monitoring Add-Ons
- **Why:** Improve visibility with tools like `kube-state-metrics` and `node-exporter`.
- **Action:** Install these add-ons using Helm.

---

## 5. Add AWS WAF for Load Balancers
- **Why:** Protect public-facing applications from web exploits.
- **Action:** Attach AWS WAF to ALBs or NLBs.

---

## 6. Implement EBS Volume Backups
- **Why:** Ensure data persistence and recovery in case of disasters.
- **Action:** Enable AWS Backup for automated snapshots of EBS volumes.

---

---

## 7. Automate Patch Management
- **Why:** Reduce downtime and improve security by automating node updates.
- **Action:** Enable automatic version updates for managed node groups.

---

## 8. Enhance Security Group Rules
- **Why:** Limit traffic to and from worker nodes for better security.
- **Action:** Restrict ingress/egress traffic to trusted IP ranges and services.

---

