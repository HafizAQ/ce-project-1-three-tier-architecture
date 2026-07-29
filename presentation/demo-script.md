
# Demo Script – AWS 3-Tier Cloud Architecture

## 1. Architecture Overview

This project implements a production-style 3-tier AWS architecture.

The architecture contains:

- Presentation Tier: Internet-facing Application Load Balancer
- Application Tier: Three private EC2 instances running a Node.js app
- Data Tier: Private database placeholder EC2 instance

Traffic flow:

User → ALB → Application EC2 → Database Placeholder

The goal is secure network segmentation, high availability, and controlled communication between tiers.

## 2. Live Demo

### Step 1: Access Application Through ALB

Open:

http://web-alb-1665614039.us-east-1.elb.amazonaws.com

Explain:

- User accesses only the ALB DNS.
- Application servers are private.
- Page shows instance ID, Availability Zone, and database status.

### Step 2: Health Check Endpoint

Run:

```bash
curl http://$ALB_DNS/health
```

Run:



Explain:

ALB uses /health to check instance availability.
Healthy targets receive traffic.


Step 3: Target Group Health

Run:

aws elbv2 describe-target-health 
  --target-group-arn "$TG_ARN" 
  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State]' 
  --output table

Explain:

All three application instances are healthy.
ALB distributes traffic only to healthy targets.
Step 4: Load Distribution

Run:

for i in {1..10}; do
  curl -s http://$ALB_DNS | grep "Instance"
done

Explain:

Different instance IDs prove load balancing.
Step 5: Security Isolation

Explain:

App instances have no public IP.
Database has no public IP.
Database allows port 3306 only from App Tier SG.
Administration uses SSM, not SSH.
3. Challenges and Solutions
Challenge 1: Targets became unhealthy

Cause:

Node.js was started with nohup, so after reboot the process stopped.

Solution:

Created a systemd service to restart the application automatically.

Challenge 2: Private EC2 access

Cause:

Instances were in private subnets with no public IP.

Solution:

Configured AWS Systems Manager Session Manager with IAM role and outbound HTTPS.

Challenge 3: Security Group naming

Cause:

Earlier web-server security group was acting as application tier SG.

Solution:

Replaced it with explicit app-tier-sg for consistency.

4. Cost Analysis

Major cost components:

EC2 instances
NAT Gateways
Application Load Balancer
EBS volumes

Cost optimization plan:

Stop EC2 when not in use
Use Auto Scaling
Use one NAT Gateway in development
Use Savings Plans for long-running workloads
5. Future Improvements

Recommended improvements:

Replace database placeholder with Amazon RDS
Add Auto Scaling Group
Add HTTPS with ACM
Add CloudWatch alarms
Add Terraform
Add CI/CD pipeline
Add AWS WAF
6. Closing

This project demonstrates:

Secure VPC design
Three-tier architecture
Load balancing
Private application and database tiers
Least privilege security
High availability
Cost-aware cloud design
