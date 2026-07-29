# Test Results

# AWS Three-Tier Cloud Architecture – Test Results

## Overview

The infrastructure was validated through a series of functional, networking, security, and availability tests.

---

# Test Result 1 – Load Balancer Access

### Method

Accessed the application using the ALB DNS name.

### Expected Result

Homepage loads successfully.

### Actual Result

Application loaded correctly and displayed:

* Instance ID
* Availability Zone
* Database Connection Status

**Status:** ✅ Passed

---

# Test Result 2 – Health Checks

### Method

Verified Target Group health using AWS CLI.

### Expected Result

Healthy application servers remain registered.

### Actual Result

Target Group correctly reported healthy and unhealthy instances during testing.

**Status:** ✅ Passed

---

# Test Result 3 – Load Distribution

### Method

Sent repeated HTTP requests to the ALB.

### Expected Result

Responses originate from different EC2 instances.

### Actual Result

Requests were successfully distributed across healthy application servers.

**Status:** ✅ Passed

---

# Test Result 4 – Health Endpoint

### Method

Accessed the `/health` endpoint.

### Expected Result

HTTP 200 response with application health status.

### Actual Result

Health endpoint returned the expected response.

**Status:** ✅ Passed

---

# Test Result 5 – Database Connectivity

### Method

Verified database connection status from the application.

### Expected Result

Application successfully communicates with the database placeholder.

### Actual Result

Database connectivity was successfully reported.

**Status:** ✅ Passed

---

# Test Result 6 – Session Manager

### Method

Connected to private EC2 instances using AWS Systems Manager.

### Expected Result

Secure shell access without SSH.

### Actual Result

Successfully connected to all required instances.

**Status:** ✅ Passed

---

# Test Result 7 – Security Validation

### Method

Verified Security Group rules and private subnet deployment.

### Expected Result

No public access to Application or Database tiers.

### Actual Result

Security Groups enforced proper isolation.

**Status:** ✅ Passed

---

# Test Result 8 – Failover Validation

### Method

Simulated an unhealthy application instance.

### Expected Result

Application Load Balancer removes unhealthy instance.

### Actual Result

Traffic continued through healthy instances with no interruption.

**Status:** ✅ Passed

---

# Overall Test Summary

| Category              | Result    |
| --------------------- | --------- |
| Networking            | ✅ Passed |
| Security              | ✅ Passed |
| Load Balancing        | ✅ Passed |
| Health Checks         | ✅ Passed |
| Database Connectivity | ✅ Passed |
| High Availability     | ✅ Passed |
| Session Manager       | ✅ Passed |

## Conclusion

All required project tests completed successfully.

The infrastructure behaves as expected under normal operation and during simulated failure scenarios, demonstrating secure networking, reliable load balancing, and high availability.
