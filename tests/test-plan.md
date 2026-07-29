
# Test Plan

# AWS Three-Tier Cloud Architecture – Test Plan

## Purpose

This document describes the testing methodology used to validate the functionality, security, availability, and networking of the deployed AWS Three-Tier Architecture.

The testing objectives were to verify that:

* All infrastructure components were deployed correctly.
* The Application Load Balancer distributed traffic properly.
* Application servers responded successfully.
* Health checks operated correctly.
* Network isolation was enforced.
* The Database Tier was reachable only from the Application Tier.
* Systems Manager could manage private EC2 instances.
* High availability and failover mechanisms worked as expected.

---

# Test Environment

## Infrastructure

* Amazon VPC
* Internet Gateway
* Two NAT Gateways
* Six Subnets
* Application Load Balancer
* Target Group
* Three EC2 Application Servers
* One Database Placeholder EC2
* AWS Systems Manager

---

# Test Cases

## Test 1 – VPC Connectivity

### Objective

Verify that all resources were deployed within the correct VPC and subnet structure.

### Expected Result

* All instances belong to the project VPC.
* Subnets are correctly associated.
* Route tables are correctly configured.

### Status

✅ Passed

---

## Test 2 – Application Load Balancer

### Objective

Verify that the ALB is reachable through its DNS name.

### Expected Result

* Homepage loads successfully.
* HTTP requests are accepted.

### Status

✅ Passed

---

## Test 3 – Target Group Health Checks

### Objective

Verify that the ALB correctly monitors backend application servers.

### Expected Result

* Healthy instances remain registered.
* Unhealthy instances are marked accordingly.

### Status

✅ Passed

---

## Test 4 – Application Availability

### Objective

Verify that the Node.js application responds correctly.

### Expected Result

Homepage displays:

* Instance ID
* Availability Zone
* Database Connection Status

### Status

✅ Passed

---

## Test 5 – Health Endpoint

### Objective

Verify the `/health` endpoint.

### Expected Result

Health endpoint returns HTTP 200 with application health information.

### Status

✅ Passed

---

## Test 6 – Database Connectivity

### Objective

Verify communication between the Application Tier and the Database Tier.

### Expected Result

Application successfully reports database connectivity status.

### Status

✅ Passed

---

## Test 7 – Load Distribution

### Objective

Verify that requests are distributed across multiple application servers.

### Expected Result

Successive requests return responses from different EC2 instances.

### Status

✅ Passed

---

## Test 8 – Session Manager

### Objective

Verify secure administration of private EC2 instances.

### Expected Result

EC2 instances are accessible through AWS Systems Manager without SSH.

### Status

✅ Passed

---

## Test 9 – Security Isolation

### Objective

Verify that backend resources are not publicly accessible.

### Expected Result

* Application servers cannot be accessed directly from the Internet.
* Database server remains isolated.

### Status

✅ Passed

---

## Test 10 – High Availability

### Objective

Verify application availability during instance failure.

### Expected Result

The ALB continues serving requests through healthy instances.

### Status

✅ Passed

---

# Summary

| Test                  | Result    |
| --------------------- | --------- |
| VPC Connectivity      | ✅ Passed |
| Load Balancer         | ✅ Passed |
| Health Checks         | ✅ Passed |
| Application           | ✅ Passed |
| Health Endpoint       | ✅ Passed |
| Database Connectivity | ✅ Passed |
| Load Distribution     | ✅ Passed |
| Session Manager       | ✅ Passed |
| Security Isolation    | ✅ Passed |
| High Availability     | ✅ Passed |

## Overall Result

**All planned tests completed successfully.**

The deployed infrastructure satisfies the functional, networking, security, and availability requirements of the project.
