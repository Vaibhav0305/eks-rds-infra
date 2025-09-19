# 🚀 EKS + RDS + CI/CD Pipeline Project

This project demonstrates a **production-ready API deployment on AWS** using modern DevOps practices.  
It provisions infrastructure with **Terraform**, containerizes the application with **Docker**, orchestrates with **EKS (Kubernetes)**, stores data in **Amazon RDS**, and implements **monitoring with Prometheus & Grafana**.  
A **GitHub Actions CI/CD pipeline** automates deployment end-to-end.

---

## 🏗️ Architecture

- **Terraform (IaC)** → Provisions VPC, EKS Cluster, RDS PostgreSQL, and ECR Repository.  
- **Docker** → Containerizes a Node.js API (`index.js`).  
- **Amazon ECR** → Stores built Docker images.  
- **EKS (Kubernetes)** → Runs the API as pods, exposed via a LoadBalancer.  
- **Amazon RDS** → PostgreSQL database backend.  
- **Prometheus & Grafana** → Monitoring & visualization stack.  
- **GitHub Actions** → CI/CD pipeline (build, push, deploy on each commit).

---

## ⚙️ Tech Stack

- **Infrastructure**: Terraform, AWS (EKS, RDS, VPC, ECR, IAM)  
- **Application**: Node.js + Express  
- **Containerization**: Docker  
- **Orchestration**: Kubernetes on Amazon EKS  
- **CI/CD**: GitHub Actions  
- **Monitoring**: Prometheus + Grafana  

---

## 🚀 Deployment Workflow

### 1️⃣ Infrastructure Setup (Terraform)
```bash
terraform init
terraform apply -var-file="terraform.tfvars"
