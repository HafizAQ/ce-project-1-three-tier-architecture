# Failover Test

# High Availability and Failover Validation

## Objective

The objective of this test was to verify that the Application Load Balancer automatically detects unhealthy application servers and routes traffic only to healthy instances.

---

# Test Scenario

The deployed infrastructure consists of:

* One Application Load Balancer
* Three EC2 Application Servers
* Target Group with Health Checks

The ALB continuously monitors each application server using the `/health` endpoint.

---

# Test Procedure

1. Confirm all application servers are healthy.
2. Access the application through the ALB DNS name.
3. Verify traffic is distributed across multiple instances.
4. Simulate an unhealthy application server.
5. Wait for the ALB health checks to detect the failure.
6. Verify that the unhealthy instance is removed from the Target Group.
7. Continue accessing the application through the ALB.
8. Verify that traffic is routed only to healthy instances.

---

# Expected Behaviour

* Health checks identify the unhealthy instance.
* The Application Load Balancer removes the instance from service.
* Client requests continue to succeed.
* Remaining healthy instances continue serving traffic.

---

# Actual Results

During testing:

* Health checks correctly detected the unhealthy instance.
* The Target Group updated the instance status.
* The Application Load Balancer stopped routing traffic to the failed instance.
* Client access remained uninterrupted.
* Healthy instances continued serving requests.

The failover process occurred automatically without manual intervention.

---

# Observations

* Application availability was maintained throughout the test.
* Load balancing continued across healthy instances.
* No changes were required from the client side.
* Recovery behaviour matched the expected design.

---

# Benefits of the Implemented Design

The failover mechanism provides:

* Improved application availability
* Automatic fault detection
* Reduced downtime
* Better user experience
* Simplified operations

---

# Future Enhancements

To further improve resilience, the following enhancements are recommended:

* Auto Scaling Group to automatically replace failed instances.
* CloudWatch Alarms for health monitoring.
* SNS notifications for operational alerts.
* Multi-Region disaster recovery.
* Automated infrastructure deployment using Infrastructure as Code.

---

# Conclusion

The failover test successfully demonstrated the high availability capabilities of the deployed AWS Three-Tier Architecture.

The Application Load Balancer detected unhealthy instances, removed them from service, and continued routing traffic to healthy application servers without impacting client access. This validates the effectiveness of the implemented load balancing and health check configuration in meeting the project's high availability objectives.








## hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ aws elbv2 describe-target-health

  --target-group-arn "$TG_ARN"

  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State]'

  --output table

  --no-cli-pager

|        DescribeTargetHealth        |
+----------------------+-------------+
|  i-0f666c34abcfc4270 |  healthy    |
|  i-076d7676f4e0a3122 |  unhealthy  |
|  i-0a1469632365a6a42 |  healthy    |
+----------------------+-------------+
hquddus@es037-nb:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ aws ssm start-session 
  --target i-076d7676f4e0a3122

Starting session with SessionId: hquddus-zydhao5cdtlktonj9itb4qejdi
sh-5.2$ sudo systemctl start three-tier-app
sudo systemctl status three-tier-app --no-pager
● three-tier-app.service - Three-Tier Node.js Application
     Loaded: loaded (/etc/systemd/system/three-tier-app.service; enabled; preset: disabled)
    Drop-In: /etc/systemd/system/three-tier-app.service.d
             └─database.conf
     Active: active (running) since Sun 2026-07-26 22:50:03 UTC; 1min 53s ago
   Main PID: 15941 (node)
      Tasks: 7 (limit: 1014)
     Memory: 12.2M
        CPU: 125ms
     CGroup: /system.slice/three-tier-app.service
             └─15941 /usr/bin/node /home/ec2-user/server.js

Jul 26 22:50:03 ip-10-0-11-141.ec2.internal systemd[1]: Started three-tier-app.service - Three-Tier Node.js Application.
sh-5.2$ exit
exit

Exiting session with sessionId: hquddus-zydhao5cdtlktonj9itb4qejdi.

h:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ aws elbv2 describe-target-health
--------------------------------------------------------------------------------------------------

  --target-group-arn "$TG_ARN"

  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]'

  --output table

  --no-cli-pager

|           DescribeTargetHealth           |
+----------------------+-----------+-------+
|  i-0f666c34abcfc4270 |  healthy  |  None |
|  i-076d7676f4e0a3122 |  healthy  |  None |
|  i-0a1469632365a6a42 |  healthy  |  None |
+----------------------+-----------+-------+
