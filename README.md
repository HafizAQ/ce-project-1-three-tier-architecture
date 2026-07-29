# Project 1: Production Ready AWS Three-Tier Cloud Architecture Deployment

> **Cloud Engineering Bootcamp – Project 1**

## Project Overview

This project demonstrates the design, implementation, and deployment of a secure, highly available, three-tier cloud architecture on Amazon Web Services (AWS). The infrastructure was built using AWS networking and compute services following cloud architecture best practices, including network segmentation, defense-in-depth security, high availability, and cost-conscious design.

The architecture consists of three logically separated tiers:

* **Presentation Tier** – Internet-facing Application Load Balancer (ALB)
* **Application Tier** – Three private EC2 instances hosting a Node.js web application
* **Data Tier** – Private EC2 instance acting as a database placeholder service

The application is accessible only through the Application Load Balancer. The Application Tier communicates securely with the Database Tier using private networking, while Systems Manager (Session Manager) is used for administration without exposing SSH to the Internet.

---

# Project Objectives

The primary objectives of this project were to:

* Design a production-style AWS Virtual Private Cloud (VPC)
* Implement a secure three-tier architecture
* Deploy resources across multiple Availability Zones
* Configure an Application Load Balancer with health checks
* Deploy multiple application servers behind the load balancer
* Secure communication between application and database tiers
* Apply the Principle of Least Privilege through Security Groups
* Demonstrate high availability and failover capabilities
* Produce professional technical documentation
* Perform cost analysis and identify production improvements

---

# Solution Architecture

The deployed infrastructure follows a traditional three-tier architecture.

```
Internet
     │
     ▼
Application Load Balancer
     │
     ▼
Application Tier
 ┌───────────────┐
 │ EC2 Instance 1│
 │ EC2 Instance 2│
 │ EC2 Instance 3│
 └───────────────┘
     │
     ▼
Database Tier
┌────────────────────┐
│ Database Placeholder(EC2)│
└────────────────────┘
```

> **Architecture Diagram:** `architecture/architecture-diagram.png`

---

# AWS Services Used

| Service                   | Purpose                             |
| ------------------------- | ----------------------------------- |
| Amazon VPC                | Isolated network environment        |
| Public & Private Subnets  | Network segmentation                |
| Internet Gateway          | Public Internet access              |
| NAT Gateway               | Internet access for private subnets |
| Route Tables              | Traffic routing                     |
| Application Load Balancer | Traffic distribution                |
| Target Groups             | Health monitoring and routing       |
| Amazon EC2                | Application and database servers    |
| Security Groups           | Instance-level firewall             |
| AWS Systems Manager       | Secure administration without SSH   |
| IAM Roles                 | Secure AWS service permissions      |

---

# Repository Structure

```text
ce-project-1-three-tier-architecture/
│
├── README.md
├── ARCHITECTURE.md
├── SECURITY.md
├── COSTS.md
├── IMPROVEMENTS.md
│
├── architecture/
│   ├── architecture-diagram.png
│   ├── network-diagram.png
│   ├── security-groups-diagram.png
│   └── traffic-flow-diagram.png
│
├── config/
│   ├── vpc-config.txt
│   ├── security-groups.txt
│   ├── load-balancer-config.txt
│   └── instances.txt
├── extra/
│   ├── vpc-config.txt
├── app/
│   ├── server.js
│   ├── package.json
│   └── deploy.sh
│
├── tests/
│   ├── test-plan.md
│   ├── test-results.md
│   └── failover-test.md
│
└── presentation/
    ├── slides.pdf
    ├── demo-script.md
    └── screenshots/
```

---

# Architecture Design

The infrastructure is divided into three independent tiers to improve security, scalability, and maintainability.

### Presentation Tier

* Internet-facing Application Load Balancer
* Public Subnets
* HTTP Listener (Port 80)
* Health Checks
* Traffic Distribution

### Application Tier

* Three EC2 instances
* Private Subnets
* Node.js Application
* Registered with Target Group
* Multi-AZ deployment

The application displays:

* EC2 Instance ID
* Availability Zone
* Database Connection Status
* `/health` endpoint

### Data Tier

* Database placeholder EC2 instance
* Private subnet
* Accessible only from the Application Tier
* No public IP address

---

# Network Design

The infrastructure uses a dedicated VPC with CIDR block planning that separates workloads into multiple security zones.

The network includes:

* One VPC
* Two Public Subnets
* Two Private Application Subnets
* Two Private Database Subnets
* Internet Gateway
* NAT Gateways
* Route Tables for each network tier

This design provides secure network isolation while allowing private instances controlled Internet access through NAT Gateways.

---

# Security Architecture

Security was implemented using a defense-in-depth approach.

### Application Load Balancer Security Group

* Allow HTTP from the Internet
* Forward traffic only to Application Tier

### Application Tier Security Group

* Accept HTTP traffic only from the ALB Security Group
* No public inbound access

### Database Tier Security Group

* Accept database traffic only from the Application Tier
* Completely isolated from the Internet

Additional security measures include:

* AWS Systems Manager Session Manager for administration
* No SSH access required
* Private networking between tiers
* Principle of Least Privilege

---

# High Availability

High availability was achieved through:

* Multi-AZ deployment
* Three application servers
* Application Load Balancer
* Health Checks
* Automatic routing to healthy instances
* NAT Gateway connectivity for private instances

If an application server becomes unhealthy, the Application Load Balancer automatically removes it from the rotation and continues serving traffic through the remaining healthy instances.

---

# Application Features

The deployed Node.js application provides:

* Instance identification
* Availability Zone display
* Database connectivity status
* Health endpoint (`/health`)
* Load balancing demonstration
* High availability validation

---

# Deployment Summary

The infrastructure was deployed using AWS CLI commands and consists of:

1. VPC creation
2. Subnet creation
3. Internet Gateway attachment
4. NAT Gateway deployment
5. Route Table configuration
6. Security Group creation
7. EC2 deployment
8. Database placeholder deployment
9. Application Load Balancer configuration
10. Target Group registration
11. Health Check configuration
12. Application deployment
13. Validation and testing

---

# Testing Performed

The following tests were successfully completed:

* VPC connectivity validation
* Route table verification
* Security Group validation
* Application accessibility through ALB
* Target Group health checks
* Load distribution across application servers
* Database connectivity
* Session Manager connectivity
* High Availability testing
* Failover validation

Detailed results are available in the `tests/` directory.

---

# Cost Analysis Summary

The deployed architecture was designed with cost awareness while maintaining high availability.

Primary cost components include:

* Amazon EC2
* Application Load Balancer
* NAT Gateways
* Elastic Block Storage (EBS)
* Data Transfer

A detailed monthly cost estimate and optimization recommendations are provided in **COSTS.md**.

---

# Challenges Encountered

Several implementation challenges were encountered and resolved during the project:

* EC2 metadata access with IMDSv2
* Application health check troubleshooting
* NAT Gateway routing configuration
* Session Manager connectivity
* Target Group health validation
* Environment variable management
* Systemd service configuration

These experiences improved practical understanding of AWS networking and troubleshooting.

---

# Lessons Learned

This project provided practical experience in:

* AWS networking
* High availability design
* Multi-tier architecture
* Security best practices
* Load balancing
* Cloud troubleshooting
* Infrastructure documentation
* Cost optimization

---

# Future Improvements

Potential production enhancements include:

* Amazon RDS
* Auto Scaling Groups
* HTTPS using ACM
* AWS WAF
* CloudWatch monitoring
* Infrastructure as Code (Terraform or CloudFormation)
* CI/CD pipeline
* Automated backups
* Disaster Recovery planning

Further details are documented in **IMPROVEMENTS.md**.

---

# Team Information

**Project Type:** Individual

**Student:** Hafiz Abdul Quddus

**Course:** Cloud Engineering Bootcamp

**Project:** AWS Three-Tier Cloud Architecture Deployment

---

# Acknowledgements

This project was developed as part of the Cloud Engineering Bootcamp to demonstrate practical knowledge of AWS networking, compute, security, high availability, and cloud infrastructure design following industry best practices.
