# 🛒 Scalable 3-Tier E-Commerce Infrastructure on AWS

This project demonstrates a fully automated, production-ready cloud architecture deployed using **Terraform (Infrastructure as Code)**. It hosts a storefront application with a decoupled frontend and a secure, high-availability backend.



## 🏗️ Architecture Overview

The infrastructure is split into three distinct layers across two Availability Zones (AZs) for high availability:

1.  **Presentation Layer (Frontend)**: 
    * **Amazon S3**: Hosts the static `index.html` storefront.
    * **Amazon CloudFront**: Acts as a Content Delivery Network (CDN) to serve the frontend with low latency globally.
2.  **Application Layer (Backend)**:
    * **Application Load Balancer (ALB)**: Distributes incoming traffic to the web servers.
    * **Amazon EC2**: Managed by an **Auto Scaling Group (ASG)** to scale based on demand.
3.  **Data Layer (Database & Cache)**:
    * **Amazon RDS (MySQL/PostgreSQL)**: A Multi-AZ relational database for persistent storage.
    * **Amazon ElastiCache (Redis)**: High-performance caching for session management.

## 🛠️ Tech Stack
* **IaC**: Terraform
* **Cloud**: AWS (VPC, EC2, RDS, S3, CloudFront, Secrets Manager)
* **Web**: HTML/JavaScript (Fetch API)
* **Security**: IAM Roles, Security Groups, NAT Gateways

## 🚀 How to Deploy

1.  **Clone the repo**:
    ```bash
    git clone [https://github.com/ugill123/aws-3tier-ecommerce-terraform.git](https://github.com/ugill123/aws-3tier-ecommerce-terraform.git)
    ```
2.  **Initialize Terraform**:
    ```bash
    terraform init
    ```
3.  **Configure Variables**: Create a `terraform.tfvars` file and add your specific configurations (e.g., region, instance types).
4.  ## ⚙️ Configuration Reference

The following values are used to define the infrastructure boundaries in `terraform.tfvars`:

| Parameter | Value | Description |
| :--- | :--- | :--- |
| **Region** | `us-east-1` | AWS Primary Region |
| **VPC CIDR** | `10.0.0.0/16` | Main Network Address Space |
| **Public Subnets** | `10.0.1.0/24`, `10.0.2.0/24` | External-facing (ALB, NAT GW) |
| **Private Subnets** | `10.0.10.0/24`, `10.0.11.0/24` | Application Layer (EC2) |
| **Database Subnets** | `10.0.20.0/24`, `10.0.21.0/24` | Data Layer (RDS, Redis) |
| **Alert Email** | `admin@example.com` | CloudWatch Alarms Destination |


5.  **Deploy**:
    
    terraform apply -auto-approve
    

## 📝 Frontend Integration (`index.html`)
The frontend is designed to be completely decoupled. Once the infrastructure is deployed, the `index.html` file is updated with the **ALB DNS Name** to communicate with the backend API.

```javascript
// Example of the Fetch call in index.html
const API_URL = "http://YOUR_ALB_DNS_NAME/api/products";

