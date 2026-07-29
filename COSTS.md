# COSTS.md

# AWS Infrastructure Cost Analysis

## Project Overview

This document provides an estimated monthly cost analysis for the AWS Three-Tier Cloud Architecture deployed as part of the Cloud Engineering Bootcamp project.

The objective of this analysis is to:

* Estimate the monthly operating cost of the deployed infrastructure.
* Identify the major cost contributors.
* Discuss cost optimization strategies.
* Evaluate return on investment (ROI).
* Estimate future scaling costs.

> **Note:** All prices are approximate and based on on-demand pricing. Actual AWS charges vary by region, usage patterns, and pricing updates.

---

# Infrastructure Components

The deployed architecture consists of:

* 1 Virtual Private Cloud (VPC)
* 2 Public Subnets
* 2 Private Application Subnets
* 2 Private Database Subnets
* 1 Internet Gateway
* 2 NAT Gateways
* 1 Application Load Balancer
* 1 Target Group
* 3 Amazon EC2 Application Servers
* 1 Amazon EC2 Database Placeholder
* Elastic Block Store (EBS) Volumes
* Security Groups
* AWS Systems Manager Session Manager

---

# Estimated Monthly Cost

| AWS Service                 |       Quantity | Estimated Monthly Cost (USD) |
| --------------------------- | -------------: | ---------------------------: |
| EC2 (Application Servers)   |  4 × t3.micro |                        $4.16 |
| Application Load Balancer   |              1 |                       $31.03 |
| NAT Gateway                 |              2 |                      $198.90 |
| Elastic Block Storage (EBS) |      4 Volumes |                        $8.65 |
| Internet Gateway            |              1 |                        $0.00 |
| VPC                         |              1 |                        $0.00 |
| Route Tables                |       Multiple |                        $0.00 |
| Security Groups             |       Multiple |                        $0.00 |
| AWS Systems Manager         | Standard Usage |                        $0.00 |

---

# Estimated Monthly Total

| Category                  |                                   Cost |
| ------------------------- | -------------------------------------: |
| Compute                   |                                  $4.90 |
| Networking                |                                $198.90 |
| Storage                   |                                  $8.65 |
| Management                |                                  $0.00 |
| **Estimated Total** | **≈ $**242.74** / month** |

The NAT Gateways account for the largest portion of the monthly cost, followed by the Application Load Balancer and EC2 instances.

---

# Major Cost Contributors

## 1. NAT Gateways

The deployment uses two NAT Gateways to provide outbound Internet access for private resources in separate Availability Zones.

### Benefits

* High availability
* Fault tolerance
* Secure outbound Internet access
* AWS best practice for production environments

### Trade-off

NAT Gateways are among the most expensive networking components in this architecture.

---

## 2. Application Load Balancer

The Application Load Balancer provides:

* Load balancing
* Health monitoring
* Automatic failover
* Single public endpoint

Although it introduces additional cost, it significantly improves application availability and reliability.

---

## 3. EC2 Instances

The infrastructure includes:

* Three application servers
* One database placeholder server

Using `t3.micro` instances provides sufficient resources for demonstration purposes while keeping compute costs relatively low.

---

## 4. Elastic Block Store (EBS)

Each EC2 instance uses an EBS volume for persistent storage.

Storage costs remain low because the project uses small General Purpose (gp3) volumes suitable for a development environment.

---

# Cost Optimization Strategies

Several design decisions were made with cost awareness in mind.

## 1. EC2 Database Placeholder

Instead of deploying Amazon RDS, the project uses an EC2 instance to simulate the database layer.

### Benefit

* Lower cost
* Simpler implementation
* Suitable for learning objectives

### Limitation

Not recommended for production environments.

---

## 2. Small Instance Types

The use of `t3.micro` instances reduces compute costs while providing sufficient performance for the project workload.

---

## 3. Minimal Storage Allocation

Only the storage required for the operating system and application was allocated, helping to reduce EBS costs.

---

## 4. Session Manager

AWS Systems Manager Session Manager replaces traditional SSH access.

Benefits include:

* No bastion host required
* No Elastic IP for administration
* Reduced operational complexity
* Improved security at no additional cost

---

# Return on Investment (ROI)

Although the architecture incurs infrastructure costs, it delivers several important operational benefits.

| Investment                | Business Benefit                              |
| ------------------------- | --------------------------------------------- |
| Application Load Balancer | Improved reliability and traffic distribution |
| Multi-AZ Deployment       | Increased availability and resilience         |
| Private Networking        | Enhanced security                             |
| Security Groups           | Reduced attack surface                        |
| Session Manager           | Secure administration without SSH             |
| Health Checks             | Automatic removal of unhealthy instances      |

These architectural choices improve service availability and security while reducing manual operational effort.

---

# Scaling Cost Projections

As demand grows, infrastructure costs will increase.

## Scenario 1 – Six Application Servers

Additional Costs:

* Three additional EC2 instances
* Additional EBS storage

The Application Load Balancer can continue serving the larger fleet without significant changes.

---

## Scenario 2 – Production Database

Replacing the EC2 database placeholder with Amazon RDS would provide:

* Automated backups
* Multi-AZ deployment
* Automatic patching
* Improved reliability

However, monthly costs would increase depending on the selected RDS instance class and storage configuration.

---

## Scenario 3 – Auto Scaling

Introducing an Auto Scaling Group would allow EC2 instances to scale dynamically based on demand.

### Advantages

* Better resource utilization
* Reduced idle compute costs
* Improved availability during traffic spikes

---

## Scenario 4 – HTTPS

Adding HTTPS using AWS Certificate Manager (ACM) would improve application security with minimal additional cost, as public ACM certificates are provided at no charge for supported AWS services.

---

# Potential Cost Savings

Several additional optimizations could reduce long-term operating costs.

* Purchase EC2 Reserved Instances or Savings Plans for predictable workloads.
* Use Auto Scaling to terminate unused instances during periods of low demand.
* Replace NAT Gateways with NAT Instances in development environments where lower availability is acceptable.
* Stop or terminate non-production resources when not in use.
* Monitor usage with AWS Cost Explorer and AWS Budgets.
* Apply lifecycle policies to manage unused storage resources.

---

# Production Cost Considerations

For a production deployment, additional AWS services would likely be required.

Examples include:

* Amazon RDS Multi-AZ
* AWS WAF
* AWS Shield
* CloudWatch Alarms
* CloudTrail
* AWS Config
* Route 53
* AWS Backup

These services would increase monthly costs but provide enhanced security, monitoring, compliance, and operational resilience.

---

# Conclusion

The implemented three-tier architecture provides a good balance between functionality, security, and cost for a learning environment. While networking components—particularly the NAT Gateways and Application Load Balancer—represent the largest share of the monthly cost, they enable secure private networking, high availability, and reliable traffic distribution.

The infrastructure is designed to be scalable and can be enhanced with production-grade services such as Amazon RDS, Auto Scaling Groups, and HTTPS without requiring major architectural changes. Overall, the design demonstrates sound cloud engineering principles while remaining aligned with the project's technical and educational objectives.
