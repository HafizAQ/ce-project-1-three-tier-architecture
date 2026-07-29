# ARCHITECTURE.md

# AWS Three-Tier Cloud Architecture Documentation

## Project Overview

This document provides a detailed technical explanation of the architecture implemented for the AWS Three-Tier Cloud Architecture Deployment project. The solution follows AWS Well-Architected Framework principles by separating the infrastructure into independent Presentation, Application, and Data tiers. This layered architecture improves security, scalability, availability, and maintainability while following cloud engineering best practices.

---

# Architecture Goals

The architecture was designed to achieve the following objectives:

* Build a secure three-tier cloud infrastructure
* Provide high availability across multiple Availability Zones
* Isolate workloads using private networking
* Protect backend resources from direct Internet access
* Distribute incoming traffic using an Application Load Balancer
* Demonstrate fault tolerance through health checks and failover
* Apply the Principle of Least Privilege throughout the infrastructure
* Create a scalable foundation suitable for future production enhancements

---

# Overall Architecture

```text
                        Internet
                            │
                            ▼
               ┌────────────────────────┐
               │ Application Load Balancer │
               │     Public Subnets        │
               └────────────┬─────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
     App Server 1     App Server 2     App Server 3
     Private Subnet   Private Subnet   Private Subnet
            │               │               │
            └───────────────┬───────────────┘
                            │
                            ▼
              Database Placeholder EC2
                 Private Data Subnet
```

---

# Architecture Layers

## 1. Presentation Layer

The Presentation Layer provides the public entry point for users accessing the application.

### Components

* Internet-facing Application Load Balancer
* Public Subnet A
* Public Subnet B

### Responsibilities

* Accept HTTP requests from clients
* Perform health checks on backend instances
* Route requests only to healthy targets
* Distribute incoming traffic evenly
* Provide a single DNS endpoint for users

### Design Decision

Using an Application Load Balancer removes the need for users to access EC2 instances directly. It improves availability, simplifies scaling, and automatically handles unhealthy backend instances.

---

## 2. Application Layer

The Application Layer hosts the business logic of the solution.

### Components

* Three Amazon EC2 instances
* Private Application Subnets
* Node.js web application
* Target Group registration

### Responsibilities

* Process client requests
* Display:

  * Instance ID
  * Availability Zone
  * Database connection status
* Respond to `/health` endpoint
* Communicate securely with the Database Tier

### Design Decision

Application servers are deployed in private subnets to prevent direct Internet access. All traffic must pass through the Application Load Balancer, significantly reducing the attack surface.

Deploying three instances across two Availability Zones provides redundancy and demonstrates high availability.

---

## 3. Data Layer

The Data Layer simulates a backend database service.

### Components

* Database Placeholder EC2
* Private Data Subnet
* Internal service on TCP Port 3306

### Responsibilities

* Simulate database connectivity
* Accept requests only from the Application Tier
* Demonstrate secure backend communication

### Design Decision

The Database Tier remains completely isolated from the public Internet. It has no public IP address and accepts traffic only from the Application Security Group, ensuring that backend resources cannot be accessed directly.

---

# Virtual Private Cloud Design

The entire infrastructure resides within a dedicated Amazon VPC.

## VPC Features

* Dedicated Virtual Private Cloud
* /16 CIDR block
* DNS Hostnames enabled
* DNS Resolution enabled

The VPC provides logical network isolation while allowing controlled communication between architecture tiers.

---

# Subnet Design

The infrastructure is distributed across two Availability Zones to improve resilience.

## Public Subnets

Purpose:

* Application Load Balancer
* Internet-facing resources
* Internet Gateway routing

Characteristics:

* Public IP assignment enabled
* Route to Internet Gateway

---

## Private Application Subnets

Purpose:

* Host application servers

Characteristics:

* No public IP addresses
* Internet access through NAT Gateway
* Receive traffic only from ALB

---

## Private Data Subnets

Purpose:

* Host backend database service

Characteristics:

* No public IP
* Completely isolated
* Accessible only from Application Tier

---

# Internet Connectivity

## Internet Gateway

The Internet Gateway allows inbound and outbound Internet communication for public resources.

Used by:

* Application Load Balancer

---

## NAT Gateway

Private EC2 instances require Internet access for:

* Operating system updates
* Package installation
* Node.js dependencies
* AWS service communication

The NAT Gateway provides outbound Internet connectivity while preventing unsolicited inbound connections.

---

# Route Table Design

Three routing domains were implemented.

## Public Route Table

Routes:

* Local VPC traffic
* Default route to Internet Gateway

---

## Application Route Table

Routes:

* Local VPC traffic
* Default route to NAT Gateway

---

## Database Route Table

Routes:

* Local VPC traffic
* Default route to NAT Gateway

This routing strategy ensures backend resources remain private while still allowing controlled outbound Internet access.

---

# Security Architecture

Security was implemented using a defense-in-depth approach.

## Application Load Balancer Security Group

Allowed:

* HTTP (80) from 0.0.0.0/0

Purpose:

Receive Internet traffic.

---

## Application Security Group

Allowed:

* HTTP only from ALB Security Group

Purpose:

Accept requests exclusively from the load balancer.

---

## Database Security Group

Allowed:

* TCP 3306 only from Application Security Group

Purpose:

Prevent all external database access.

---

# Traffic Flow

The application request follows these steps:

1. Client sends request to ALB DNS.
2. ALB listener receives HTTP request.
3. Target Group selects a healthy application server.
4. Selected EC2 processes the request.
5. Application checks connectivity to the Database Tier.
6. Response is returned to the client through the ALB.

No component in the Application or Data Tier is directly reachable from the Internet.

---

# High Availability Strategy

High availability was implemented using several AWS features.

### Multi-Availability Zone Deployment

Application instances are distributed across two Availability Zones.

Benefits:

* Protection against Availability Zone failure
* Improved resilience
* Better service continuity

---

### Application Load Balancer

Benefits:

* Even traffic distribution
* Automatic health monitoring
* Removes unhealthy targets
* Simplifies client access

---

### Health Checks

Each application instance exposes a dedicated `/health` endpoint.

The Application Load Balancer continuously monitors these endpoints.

If an instance becomes unhealthy:

* It is automatically removed from service.
* Traffic is routed only to healthy instances.
* Users experience minimal service disruption.

---

# Scalability Considerations

Although Auto Scaling Groups were not implemented, the architecture was intentionally designed to support future scaling.

Potential enhancements include:

* Auto Scaling Group
* Launch Templates
* Amazon RDS
* Elasticache
* CloudFront
* Route 53
* AWS WAF

These services can be integrated without requiring major architectural changes.

---

# Architecture Trade-offs

| Decision                       | Benefit                                 | Trade-off                     |
| ------------------------------ | --------------------------------------- | ----------------------------- |
| EC2 Database Placeholder       | Simple, inexpensive, easy to understand | Not production-grade          |
| Application Load Balancer      | High availability and health monitoring | Additional monthly cost       |
| Private Application Tier       | Strong security                         | More complex networking       |
| NAT Gateway                    | Secure outbound Internet access         | Increases infrastructure cost |
| Session Manager instead of SSH | Eliminates public SSH exposure          | Requires IAM configuration    |

---

# Compliance with Project Requirements

| Requirement                     | Status       |
| ------------------------------- | ------------ |
| VPC with /16 CIDR               | ✅ Completed |
| Six Subnets                     | ✅ Completed |
| Multi-AZ Deployment             | ✅ Completed |
| Internet Gateway                | ✅ Completed |
| NAT Gateway                     | ✅ Completed |
| Route Tables                    | ✅ Completed |
| Application Load Balancer       | ✅ Completed |
| Health Checks                   | ✅ Completed |
| Three Application EC2 Instances | ✅ Completed |
| Database Placeholder            | ✅ Completed |
| Tier Isolation                  | ✅ Completed |
| Security Groups                 | ✅ Completed |
| Least Privilege                 | ✅ Completed |
| High Availability               | ✅ Completed |

---

# Conclusion

The implemented architecture successfully demonstrates a secure and highly available AWS three-tier deployment using industry-standard networking and security practices. By combining VPC segmentation, private application and database tiers, Application Load Balancer routing, Security Group isolation, and Session Manager administration, the solution provides a solid foundation that can be expanded into a production-ready environment with minimal architectural changes.

The design balances security, availability, scalability, and cost while satisfying all mandatory project requirements and demonstrating core cloud engineering concepts.
