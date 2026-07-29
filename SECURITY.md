
# SECURITY.md

# Security Architecture

## Project Overview

Security is one of the most important aspects of any cloud infrastructure. This project follows the **Defense in Depth** security model by implementing multiple layers of protection throughout the infrastructure. Every tier has its own security controls, and communication between tiers is explicitly allowed only where required.

The infrastructure is designed to minimize the attack surface while maintaining functionality, high availability, and ease of administration.

---

# Security Objectives

The primary security objectives of this project were to:

* Protect infrastructure from unauthorized access
* Isolate each application tier
* Restrict communication using Security Groups
* Eliminate direct administrative access through SSH
* Apply the Principle of Least Privilege
* Secure communication between application components
* Protect backend resources from Internet exposure

---

# Defense in Depth Strategy

The implemented architecture applies security at multiple layers:

```text
Internet
    │
    ▼
Application Load Balancer
(Security Group)
    │
    ▼
Application Tier
(Security Group)
    │
    ▼
Database Tier
(Security Group)
```

Each layer provides an additional security boundary, ensuring that a compromise in one layer does not automatically expose the next layer.

---

# Network Isolation

The Virtual Private Cloud (VPC) is divided into three logical network tiers.

## Presentation Tier

Components:

* Application Load Balancer

Characteristics:

* Located in Public Subnets
* Publicly accessible
* Receives HTTP traffic from users

Purpose:

Provide a secure entry point to the application without exposing backend resources.

---

## Application Tier

Components:

* Three Amazon EC2 instances

Characteristics:

* Private Subnets
* No Public IP addresses
* Accessible only through the Application Load Balancer

Purpose:

Host the application logic while remaining isolated from the Internet.

---

## Data Tier

Components:

* Database Placeholder EC2

Characteristics:

* Private Data Subnet
* No Public IP
* Accessible only from the Application Tier

Purpose:

Protect backend data services from direct external access.

---

# Security Groups

Security Groups act as virtual firewalls that control inbound and outbound traffic for each tier.

---

## 1. Application Load Balancer Security Group

### Purpose

Allow users on the Internet to access the web application.

### Inbound Rules

| Protocol | Port | Source    | Purpose            |
| -------- | ---- | --------- | ------------------ |
| HTTP     | 80   | 0.0.0.0/0 | Allow web traffic  |
| HTTPS*   | 443  | 0.0.0.0/0 | Future enhancement |

### Outbound Rules

| Destination                     | Purpose                     |
| ------------------------------- | --------------------------- |
| Application Tier Security Group | Forward application traffic |

---

## 2. Application Tier Security Group

### Purpose

Protect the application servers by allowing traffic only from the Application Load Balancer.

### Inbound Rules

| Protocol | Port | Source             | Purpose                 |
| -------- | ---- | ------------------ | ----------------------- |
| HTTP     | 80   | ALB Security Group | Web application traffic |

### Outbound Rules

| Destination                  | Port   | Purpose                                   |
| ---------------------------- | ------ | ----------------------------------------- |
| Database Tier Security Group | 3306   | Database communication                    |
| Internet (via NAT Gateway)   | 80/443 | Package updates and software installation |

No direct Internet traffic is permitted into the Application Tier.

---

## 3. Database Tier Security Group

### Purpose

Protect the backend database service.

### Inbound Rules

| Protocol | Port | Source                          | Purpose         |
| -------- | ---- | ------------------------------- | --------------- |
| TCP      | 3306 | Application Tier Security Group | Database access |

### Outbound Rules

Default outbound rules were retained to allow system updates through the NAT Gateway when required.

The Database Tier cannot be reached directly from:

* Internet
* Application Load Balancer
* Public Subnets

Only application servers are permitted to establish connections.

---

# Principle of Least Privilege

The infrastructure follows the Principle of Least Privilege by granting only the minimum permissions required for each component.

Examples include:

* Application servers accept traffic only from the ALB.
* Database server accepts traffic only from the Application Tier.
* No unrestricted access between tiers.
* No unnecessary open ports.
* No direct administrative access from the Internet.

This reduces the potential impact of accidental misconfiguration or malicious activity.

---

# Secure Administration

Traditional SSH access was intentionally not used.

Instead, administration is performed through **AWS Systems Manager Session Manager**.

Benefits include:

* No public SSH ports
* No SSH key management
* Encrypted management sessions
* Audit-friendly administrative access
* Reduced attack surface

This approach aligns with AWS security best practices for managing private EC2 instances.

---

# IAM Roles

IAM Roles were assigned to EC2 instances to enable secure interaction with AWS Systems Manager.

Benefits of IAM Roles:

* Temporary AWS credentials
* No hardcoded access keys
* Automatic credential rotation
* Secure service authentication

Using IAM Roles eliminates the need to store AWS credentials on EC2 instances.

---

# Private Networking

Communication between application components occurs entirely over private IP addresses within the VPC.

Examples include:

* ALB → Application Tier
* Application Tier → Database Tier
* Session Manager → Private EC2 instances

No backend communication traverses the public Internet.

---

# Health Check Security

The Node.js application exposes a dedicated `/health` endpoint for the Application Load Balancer.

Purpose:

* Verify application availability
* Detect unhealthy instances
* Remove failed instances automatically

The endpoint returns only basic application health information and does not expose sensitive infrastructure details.

---

# Database Protection

The Database Tier implements multiple layers of protection:

* Private subnet deployment
* No public IP address
* Dedicated Security Group
* Restricted inbound rules
* Accessible only from the Application Tier

This prevents direct access from users or the Internet.

---

# High Availability and Security

Security and availability work together in this architecture.

If an application instance becomes unhealthy:

1. The ALB health check detects the failure.
2. The instance is removed from the Target Group.
3. Traffic is routed only to healthy instances.
4. Application availability is maintained without compromising security.

---

# Security Best Practices Applied

The following AWS security best practices were implemented:

* Dedicated VPC
* Multi-tier network segmentation
* Private Application Tier
* Private Database Tier
* Security Group isolation
* Principle of Least Privilege
* Session Manager instead of SSH
* IAM Roles for EC2
* Application Load Balancer
* Health Checks
* Multi-AZ deployment
* Private internal communication
* No public database exposure

---

# Potential Vulnerabilities and Mitigations

| Potential Risk                       | Mitigation Implemented                                  |
| ------------------------------------ | ------------------------------------------------------- |
| Direct access to application servers | Application servers deployed in private subnets         |
| Database exposed to Internet         | Database deployed in private subnet with no public IP   |
| Unauthorized database access         | Security Group allows access only from Application Tier |
| SSH brute-force attacks              | SSH disabled; Session Manager used for administration   |
| Single application server failure    | Three application servers behind an ALB                 |
| Traffic sent to failed instances     | ALB health checks remove unhealthy targets              |
| Credential exposure                  | IAM Roles used instead of access keys                   |

---

# Production Security Improvements

For a production environment, the following enhancements are recommended:

* HTTPS using AWS Certificate Manager (ACM)
* AWS Web Application Firewall (WAF)
* AWS Shield Standard/Advanced
* AWS Network Firewall
* VPC Flow Logs
* AWS CloudTrail
* AWS GuardDuty
* AWS Config
* Amazon Inspector
* Secrets Manager or Parameter Store for application secrets
* Multi-Factor Authentication (MFA) for AWS accounts

These services would provide enhanced protection, monitoring, auditing, and compliance capabilities.

---

# Security Summary

This project demonstrates a secure implementation of a three-tier AWS architecture using industry-standard security practices. Network segmentation, Security Group isolation, private networking, IAM Roles, and AWS Systems Manager combine to provide a layered security model that protects critical infrastructure while maintaining availability and operational simplicity.

The design successfully meets the project's security objectives by ensuring that backend resources remain isolated, administrative access is secure, and communication between tiers is tightly controlled according to the Principle of Least Privilege.
