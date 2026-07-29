****Name:** Hafiz Abdul Quddus
**Date:** 29-07-2026**

**Architecture Design Components**

* ✅ **1 VPC**
* ✅ **1 Internet Gateway (IGW)**
* ✅ **2 Availability Zones**
* ✅ **2 Public Subnets** (one in each AZ)
* ✅ **2 NAT Gateways** (one in each public subnet/AZ)
* ✅ **2 Application Private Subnets** (one in each AZ)
* ✅ **2 Database Private Subnets** (one in each AZ)
* **Database has no internet access (most common):** **4 route tables**
* **Application Load Balncer (ALB)**

| Route Table                    | Associated Subnets                        | Default Route                            |
| ------------------------------ | ----------------------------------------- | ---------------------------------------- |
| **Public Route Table**   | Public Subnet AZ1 + Public Subnet AZ2     | `0.0.0.0/0 → Internet Gateway`        |
| **App Route Table AZ1**  | Application Subnet AZ1                    | `0.0.0.0/0 → NAT Gateway AZ1`         |
| **App Route Table AZ2**  | Application Subnet AZ2                    | `0.0.0.0/0 → NAT Gateway AZ2`         |
| **Database Route Table** | Database Subnet AZ1 + Database Subnet AZ2 | Usually only`local`(no internet route) |

**Diagram**

Internet
                        |
                  Internet Gateway
                        |
                 Public Route Table
                        |
         +-----------------------------+
         |                             |
 Public Subnet AZ1              Public Subnet AZ2
    NAT Gateway AZ1               NAT Gateway AZ2
         |                             |
 App RT AZ1                       App RT AZ2
         |                             |
 App Subnet AZ1                  App Subnet AZ2
         |                             |
         +-------------+---------------+
                       |
    Database Route Table
               /
    DB Subnet AZ1         DB Subnet AZ2

**Steps:**

**Step 1: Network Infrastructure (25%)**

    1. VPC with /16 CIDR block (Created using CLI)

*hX@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ # Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=three-tier-project-vpc}]'
  --query 'Vpc.VpcId' --output text)*

*echo "VPC ID: $VPC_ID"*

*Enable DNS hostnames*

*aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
VPC ID: vpc-0b8abdf55187111a2*

2. 6 subnets across 2 Availability Zones: 2 public subnets (presentation tier), 2 private subnets (application tier), 2 private subnets (data tier)

~hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ PRIVATE_SUBNET_1=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.1.0/24
  --availability-zone us-east-1a
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=app-private-subnet-1a}]'
  --query 'Subnet.SubnetId' --output text)

~hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ PRIVATE_SUBNET_2=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.2.0/24
  --availability-zone us-east-1b
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=app-private-subnet-1b}]'
  --query 'Subnet.SubnetId' --output text)

hxxx@xx: ~/Ironhack/Week3/project1/ce-project-1-three-tier-~

 hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ PRIVATE_SUBNET_1=$(aws ec2 create-subnet \ create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.11.0/24
  --availability-zone us-east-1a
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=app-private-subnet-1a}]'
  --query 'Subnet.SubnetId' --output text)
hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ PRIVATE_SUBNET_2=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.12.0/24
  --availability-zone us-east-1b
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=app-private-subnet-1b}]'
  --query 'Subnet.SubnetId' --output text)
hxxx@xx: ~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ RIVATE_SUBNET_3=$ (aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.31.0/24
  --availability-zone us-east-1a
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=db-private-subnet-1a}]'
  --query 'Subnet.SubnetId' --output text)
hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ RIVATE_SUBNET_4=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.32.0/24
  --availability-zone us-east-1b
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=db-private-subnet-1b}]'
  --query 'Subnet.SubnetId' --output text)

hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ PRIVATE_SUBNET_3=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.31.0/24
  --availability-zone us-east-1a
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=db-private-subnet-1a}]'
  --query 'Subnet.SubnetId' --output text)
hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$  PRIVATE_SUBNET_4=$(aws ec2 create-subnet
  --vpc-id $VPC_ID
  --cidr-block 10.0.32.0/24
  --availability-zone us-east-1b
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=db-private-subnet-1b}]'
  --query 'Subnet.SubnetId' --output text)

3. Internet Gateway attached to VPC: NAT Gateway (at least 1) for private subnet internet access

   ii) Internet Gateway and attached to VPC

   hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ # Create IGW

   IGW_ID=$(aws ec2 create-internet-gateway \

   --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=three-tier-igw}]' \

   --query 'InternetGateway.InternetGatewayId' --output text)

   echo "IGW ID: $IGW_ID"

   # Attach to VPC

   aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

   IGW ID: igw-04ca84f98d437db94

   i) Allocate Elastic IP (EIP)

hquddus@es037-nb:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ # Allocate EIP
EIP_ALLOC_1a=$(aws ec2 allocate-address --domain vpc
  --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=three-tier-nat-gateway-1a-eip}]'
  --query 'AllocationId' --output text)

echo "EIP Allocation ID: $EIP_ALLOC_1a"
EIP Allocation ID: eipalloc-05f7aa8cbc534b8a0
hquddus@es037-nb:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ # Allocate EIP
EIP_ALLOC_1b=$(aws ec2 allocate-address --domain vpc
  --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=three-tier-nat-gateway-1b-eip}]'
  --query 'AllocationId' --output text)

echo "EIP Allocation ID: $EIP_ALLOC_1b"
EIP Allocation ID: eipalloc-0395cf6d0d0addbf7

    => iii) 2 NAT Gateway

hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ NAT_GW_1a=$(aws ec2 create-nat-gateway
  --subnet-id $PUBLIC_SUBNET_1
  --allocation-id $EIP_ALLOC_1a
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=three-tier-nat-1a-gw}]'
  --query 'NatGateway.NatGatewayId' --output text)

echo "NAT Gateway ID: $NAT_GW_1a"
NAT Gateway ID: nat-01a042676289ef3dd
hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_1a
echo "NAT Gateway 1a is now available!"
NAT Gateway 1a is now available!
hxxx@xxx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ NAT_GW_1b=$(aws ec2 create-nat-gateway
  --subnet-id $PUBLIC_SUBNET_2
  --allocation-id $EIP_ALLOC_1b
  --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=three-tier-nat-1b-gw}]'
  --query 'NatGateway.NatGatewayId' --output text)

echo "NAT Gateway ID: $NAT_GW_1b"
NAT Gateway ID: nat-0910633345378aa19
hxxx@xx:~/Ironhack/Week3/project1/ce-project-1-three-tier-architecture$ aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_1b
echo "NAT Gateway 1b is now available!"
NAT Gateway 1a is now available!

5. Route tables properly configured

 i) Create public Route Table

PUBLIC_RT=$(aws ec2 create-route-table
  --vpc-id $VPC_ID
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=public-rt}]'
  --query 'RouteTable.RouteTableId'
  --output text)

#Add route to IGW

aws ec2 create-route
  --route-table-id $PUBLIC_RT
  --destination-cidr-block 0.0.0.0/0
  --gateway-id $IGW_ID

#Associate with public subnets

aws ec2 associate-route-table
  --route-table-id $PUBLIC_RT
  --subnet-id $PUBLIC_SUBNET_1

aws ec2 associate-route-table
  --route-table-id $PUBLIC_RT
  --subnet-id $PUBLIC_SUBNET_2

ii) Create Application Route Table (AZ1)

APP_RT_1=$(aws ec2 create-route-table
  --vpc-id $VPC_ID
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=app-rt-1a}]'
  --query 'RouteTable.RouteTableId'
  --output text)

aws ec2 create-route
  --route-table-id $APP_RT_1
  --destination-cidr-block 0.0.0.0/0
  --nat-gateway-id $NAT_GW_1a

aws ec2 associate-route-table
  --route-table-id $APP_RT_1
  --subnet-id $PRIVATE_SUBNET_1

iii) Create Application Route Table (AZ2)

APP_RT_2=$(aws ec2 create-route-table
  --vpc-id $VPC_ID
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=app-rt-1b}]'
  --query 'RouteTable.RouteTableId'
  --output text)

aws ec2 create-route
  --route-table-id $APP_RT_2
  --destination-cidr-block 0.0.0.0/0
  --nat-gateway-id $NAT_GW_1b

aws ec2 associate-route-table
  --route-table-id $APP_RT_2
  --subnet-id $PRIVATE_SUBNET_2

iv) Create Database Route Table

DB_RT=$(aws ec2 create-route-table
  --vpc-id $VPC_ID
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=db-rt}]'
  --query 'RouteTable.RouteTableId'
  --output text)

aws ec2 associate-route-table
  --route-table-id $DB_RT
  --subnet-id $PRIVATE_SUBNET_3

aws ec2 associate-route-table
  --route-table-id $DB_RT
  --subnet-id $PRIVATE_SUBNET_4

| Route Table   | Associated Subnets                        | Default Route                |
| ------------- | ----------------------------------------- | ---------------------------- |
| `public-rt` | `PUBLIC_SUBNET_1`,`PUBLIC_SUBNET_2`   | `0.0.0.0/0 → IGW`         |
| `app-rt-1a` | `PRIVATE_SUBNET_1`                      | `0.0.0.0/0 → NAT_GW_1a`   |
| `app-rt-1b` | `PRIVATE_SUBNET_2`                      | `0.0.0.0/0 → NAT_GW_1b`   |
| `db-rt`     | `PRIVATE_SUBNET_3`,`PRIVATE_SUBNET_4` | Only`10.0.0.0/16 → local` |

============================================================================================================

**Step 2:  Tier 1: Presentation Layer (15%)**

Application Load Balancer (internet-facing)

Deployed in public subnets across 2 AZs

Listener on port 80 (HTTP)

Health check configured

=> Solution

i) userdata.sh (added)

ii) Create security group for ALB (Application Load Balancer) and Web Server Security Group

a) ALB Security Group

ALB_SG=$(aws ec2 create-security-group \

  --group-name alb-sg \

  --description "Security group for Application Load Balancer" \

  --vpc-id $VPC_ID \

  --query 'GroupId' --output text)

#Allow HTTP from anywhere

aws ec2 authorize-security-group-ingress \

  --group-id $ALB_SG \

  --protocol tcp --port 80 --cidr 0.0.0.0/0

b) Web Security Group

WEB_SG=$(aws ec2 create-security-group
  --group-name web-servers-sg
  --description "Security group for web servers"
  --vpc-id $VPC_ID
  --query 'GroupId' --output text)

 #Allow HTTP from ALB only

aws ec2 authorize-security-group-ingress
  --group-id $WEB_SG
  --protocol tcp --port 80 --source-group $ALB_SG

iii) Retieve the latest Amazon Linux 2023 AMI

export AMI_ID=$(aws ssm get-parameter \

  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \

  --query 'Parameter.Value' \

  --output text)

echo "AMI ID: $AMI_ID"

====================================================================================================

**Step 3. Tier 2: Application Layer (20%)**

Minimum 3 EC2 instances running web application
Deployed in private subnets across 2 AZs
Registered with ALB target group
Application displays:
Instance ID
Availability Zone
Database connection status
Health check endpoint (/health)

i) Launch EC2 instances in multiple AZ s

a)  Instance 1 EC2 in AZ A

INSTANCE_1=$(aws ec2 run-instances
  --image-id "$AMI_ID"
  --instance-type t3.micro
  --key-name bootcamp-week2-key
  --security-group-ids "$WEB_SG"
  --subnet-id "$PRIVATE_SUBNET_1"
  --user-data file://userdata.sh
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1a}]'
  --query 'Instances[0].InstanceId'
  --output text)

echo "Instance 1: $INSTANCE_1"

b) Instance 2 EC2 in AZ A

INSTANCE_2=$(aws ec2 run-instances
  --image-id "$AMI_ID"
  --instance-type t3.micro
  --key-name bootcamp-week2-key
  --security-group-ids "$WEB_SG"
  --subnet-id "$PRIVATE_SUBNET_1"
  --user-data file://userdata.sh
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1a-2}]'
  --query 'Instances[0].InstanceId'
  --output text)

echo "Instance 2: $INSTANCE_2"

c) Instance 2 EC2 in AZ  B

INSTANCE_3=$(aws ec2 run-instances
  --image-id "$AMI_ID"
  --instance-type t3.micro
  --key-name bootcamp-week2-key
  --security-group-ids "$WEB_SG"
  --subnet-id "$PRIVATE_SUBNET_2"
  --user-data file://userdata.sh
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server-1b}]'
  --query 'Instances[0].InstanceId'
  --output text)

echo "Instance 3: $INSTANCE_3"

ii) Create the Target Group

TG_ARN=$(aws elbv2 create-target-group
  --name web-servers-tg
  --protocol HTTP
  --port 80
  --vpc-id "$VPC_ID"
  --health-check-protocol HTTP
  --health-check-path /health
  --health-check-interval-seconds 10
  --health-check-timeout-seconds 5
  --healthy-threshold-count 2
  --unhealthy-threshold-count 2
  --query 'TargetGroups[0].TargetGroupArn'
  --output text)

echo "Target Group ARN: $TG_ARN"

iii) Register the EC2 Instances

aws elbv2 register-targets
  --target-group-arn "$TG_ARN"
  --targets
    "Id=$INSTANCE_1"
    "Id=$INSTANCE_2"
    "Id=$INSTANCE_3"

sleep 30

#checking target health

aws elbv2 describe-target-health
  --target-group-arn "$TG_ARN"

#A concise health status command

aws elbv2 describe-target-health
  --target-group-arn "$TG_ARN"
  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]'
  --output table

iv) Create the Application Load Balancer (ALB)

ALB_ARN=$(aws elbv2 create-load-balancer
  --name web-alb
  --subnets "$PUBLIC_SUBNET_1" "$PUBLIC_SUBNET_2"
  --security-groups "$ALB_SG"
  --scheme internet-facing
  --type application
  --query 'LoadBalancers[0].LoadBalancerArn'
  --output text)

echo "ALB ARN: $ALB_ARN"

#ALB available ?

aws elbv2 wait load-balancer-available
  --load-balancer-arns "$ALB_ARN"

#ALB DNS name

ALB_DNS=$(aws elbv2 describe-load-balancers
  --load-balancer-arns "$ALB_ARN"
  --query 'LoadBalancers[0].DNSName'
  --output text)

echo "ALB DNS: $ALB_DNS"

vii) Ceate Listener: ####Listener: Accepting HTTP traffic on port 80 and forwarding it to the target group

LISTENER_ARN=$(aws elbv2 create-listener \

  --load-balancer-arn "$ALB_ARN" \

  --protocol HTTP \

  --port 80 \

  --default-actions "Type=forward,TargetGroupArn=$TG_ARN" \

  --query 'Listeners[0].ListenerArn' \

  --output text)

echo "Listener ARN: $LISTENER_ARN"

viii) Test the Load Balancer

a) Test 1: Basic Connectivity

- Tets the main page: curl "http://$ALB_DNS"
- Check only the HTTP status code (200 for OK): curl -s -o /dev/null -w "%{http_code}\n" "http://$ALB_DNS"

b) Tets 2: Health-Check Enpoint:

    curl "http://$ALB_DNS/health"

c) Test 3: Load Distribution

Make 20 requests and extract the Instance ID from the `/health` JSON response:

```shell
for i in {1..20}; do
  curl -s "http://$ALB_DNS/health"
  echo
done
```

When `jq` is installed, use:

```shell
for i in {1..20}; do
  curl -s "http://$ALB_DNS/health" | jq -r '.instance'
done | sort | uniq -c
```

Without `jq`, use:

```shell
for i in {1..20}; do
  curl -s "http://$ALB_DNS/health" \
    | sed -n 's/.*"instance":"\([^"]*\)".*/\1/p'
done | sort | uniq -c
```

d) Test 4: Simulate and Instance Failure

Stop Instance 1:

```shell
aws ec2 stop-instances \
  --instance-ids "$INSTANCE_1"
```

Wait until it is stopped:

```shell
aws ec2 wait instance-stopped \
  --instance-ids "$INSTANCE_1"
```

Wait for the target group to update:

```shell
sleep 30
```

Check target health:

```shell
aws elbv2 describe-target-health \
  --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table
```

The stopped instance may appear as:

```
unused    Target.InvalidState
```

This is expected because a stopped EC2 instance cannot receive traffic.

The two running instances should remain healthy.

Test load distribution again:

```shell
for i in {1..10}; do
  curl -s "http://$ALB_DNS/health" \
    | sed -n 's/.*"instance":"\([^"]*\)".*/\1/p'
done | sort | uniq -c
```

e) Test 5: Restore the Stopped Instance

Restart Instance 1:

```shell
aws ec2 start-instances \
  --instance-ids "$INSTANCE_1"
```

Wait until it is running:

```shell
aws ec2 wait instance-running \
  --instance-ids "$INSTANCE_1"
```

Allow time for user services and health checks:

```shell
sleep 60
```

Check the target health again:

```shell
aws elbv2 describe-target-health \
  --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table
```

If the restarted instance remains unhealthy, inspect its application log:

```shell
sudo cat /home/ec2-user/server.log
```

Also test the local endpoint from inside the instance:

```shell
curl http://localhost/health
```

==========================================================================================
4. Tier 3: Data Layer (10%)

Database placeholder (can use EC2 with simulated DB)
OR RDS database (bonus points)
Deployed in isolated private subnet
Only accessible from application tier

i) Security Groups:

1. alb-sg         → Allow 80,443 from 0.0.0.0/0
2. app-tier-sg    → Allow 80,443 from alb-sg
3. data-tier-sg   → Allow 3306/5432 from app-tier-sg only

ii)  DATA_SG=$(aws ec2 create-security-group \

  --group-name data-tier-sg \

  --description "Security group for database tier" \

  --vpc-id $VPC_ID \

  --query 'GroupId' --output text)

# Allow MySQL from App Tier ONLY

aws ec2 authorize-security-group-ingress \

  --group-id $DATA_SG \

  --protocol tcp --port 3306 --source-group $APP_TIER_SG

# Allow PostgreSQL from App Tier ONLY

aws ec2 authorize-security-group-ingress \

  --group-id $DATA_SG \

  --protocol tcp --port 5432 --source-group $APP_TIER_SG

echo "Data Tier SG: $DATA_SG"

iii) Associate with private route table

aws ec2 associate-route-table --route-table-id $`DB_RT`--subnet-id $`PRIVATE_SUBNET_3`
aws ec2 associate-route-table --route-table-id $`DB_RT`--subnet-id $`PRIVATE_SUBNET_4`

iii) Create or retrieve the Data Tier security group

DATA_SG=$(aws ec2 describe-security-groups \

  --filters \

    "Name=vpc-id,Values=$VPC_ID" \

    "Name=group-name,Values=data-tier-sg" \

  --query 'SecurityGroups[0].GroupId' \

  --output text \

  --no-cli-pager)

if [ "$DATA_SG" = "None" ]; then

  DATA_SG=$(aws ec2 create-security-group \

    --group-name data-tier-sg \

    --description "Security group for database tier" \

    --vpc-id "$VPC_ID" \

    --query 'GroupId' \

    --output text \

    --no-cli-pager)

fi

export DATA_SG

echo "Data Tier SG: $DATA_SG"

echo "App Tier SG:  $APP_TIER_SG"

iv)  Choose the data base engine: Part 3: Create Security Groups (15 min)

    You already have:

    export ALB_SG=sg-03b672bea8bfb5eee

    export APP_TIER_SG=sg-0d9683c972aba4863

    Your existing WEB_SG is being used as the Application Tier security group:

    export APP_TIER_SG="$WEB_SG"

    1. Create or retrieve the Data Tier security group

    DATA_SG=$(aws ec2 describe-security-groups \

    --filters \

    "Name=vpc-id,Values=$VPC_ID" \

    "Name=group-name,Values=data-tier-sg" \

    --query 'SecurityGroups[0].GroupId' \

    --output text \

    --no-cli-pager)

    if [ "$DATA_SG" = "None" ]; then

    DATA_SG=$(aws ec2 create-security-group \

    --group-name data-tier-sg \

    --description "Security group for database tier" \

    --vpc-id "$VPC_ID" \

    --query 'GroupId' \

    --output text \

    --no-cli-pager)

    fi

    export DATA_SG

    echo "Data Tier SG: $DATA_SG"

    echo "App Tier SG:  $APP_TIER_SG"

    Expected values in your environment:	Data Tier SG: sg-097b91305f3504c9f

    App Tier SG:  sg-0d9683c972aba4863

    2. Allow MySQL from the Application Tier only

    aws ec2 authorize-security-group-ingress \

    --group-id "$DATA_SG" \

    --protocol tcp \

    --port 3306 \

    --source-group "$APP_TIER_SG" \

    --no-cli-pager 2>/dev/null \

    || echo "MySQL ingress rule already exists"

This creates the following path:

Application Tier SG

sg-0d9683c972aba4863

    │

    │ TCP 3306

    ▼

Data Tier SG

sg-097b91305f3504c9f

Do not allow port 3306 from 0.0.0.0/0.

3. Allow Application Tier outbound traffic to the Data Tier

The original --destination-group option is invalid. Use --ip-permissions:

aws ec2 authorize-security-group-egress \

  --group-id "$APP_TIER_SG" \

  --ip-permissions \

  "IpProtocol=tcp,FromPort=3306,ToPort=3306,UserIdGroupPairs=[{GroupId=$DATA_SG}]" \

  --no-cli-pager 2>/dev/null \

  || echo "MySQL egress rule already exists"

4. Remove obsolete Data Tier rules

Your Data Tier security group currently has old rules referencing:

sg-03e745f582cea2f21

Your correct current Application Tier security group is:

sg-0d9683c972aba4863

Remove only the old inbound rules:

OLD_RULE_IDS=$(aws ec2 describe-security-group-rules \

  --filters "Name=group-id,Values=$DATA_SG" \

  --query 'SecurityGroupRules[

    ?IsEgress==`false` &&

    ReferencedGroupInfo.GroupId==`sg-03e745f582cea2f21`

  ].SecurityGroupRuleId' \

  --output text \

  --no-cli-pager)

if [ -n "$OLD_RULE_IDS" ] && [ "$OLD_RULE_IDS" != "None" ]; then

  aws ec2 revoke-security-group-ingress \

    --group-id "$DATA_SG" \

    --security-group-rule-ids $OLD_RULE_IDS \

    --no-cli-pager

fi

5. Verify the Data Tier inbound rules

aws ec2 describe-security-group-rules \

  --filters "Name=group-id,Values=$DATA_SG" \

  --query 'SecurityGroupRules[

    ?IsEgress==`false`

  ].[IpProtocol,FromPort,ToPort,ReferencedGroupInfo.GroupId]' \

  --output table \

  --no-cli-pager

Expected result:

---

|          DescribeSecurityGroupRules           |

+-----+-------+-------+-------------------------+

| tcp | 3306  | 3306  | sg-0d9683c972aba4863   |

+-----+-------+-------+-------------------------+

6. Verify Application Tier outbound rules

aws ec2 describe-security-group-rules \

  --filters "Name=group-id,Values=$APP_TIER_SG" \

  --query 'SecurityGroupRules[

    ?IsEgress==`true`

  ].[IpProtocol,FromPort,ToPort,CidrIpv4,ReferencedGroupInfo.GroupId]' \

  --output table \

  --no-cli-pager

The database-specific rule should appear as:

tcp   3306   3306   None   sg-097b91305f3504c9f

You may also see:

-1   -1   -1   0.0.0.0/0   None

This is the default outbound rule. Keep it for now because the private application servers may require NAT Gateway access for package installation and software updates.

Final security flow

Internet

   │

   │ HTTP 80

   ▼

ALB Security Group

   │

   │ HTTP 80

   ▼

Application Tier Security Group

   │

   │ MySQL TCP 3306

   ▼

Data Tier Security Group

   │

   ▼

RDS MySQL database

Part 3 result: The database tier accepts MySQL connections only from instances associated with the Application Tier security group.

=============================================================================

===> Major mistak: As I am using EC2 instances in private subnet and I don't have direct access to know whether are they down or not, I nned bastian host or session manager

===> I use Session Manager configuration service (SSM) to access EC2 private instances without accessing through ssh or assigning the public ip (only using SSM Agent)

i) temp added the outbound rule of HTTP through NAT Gateways

aws ec2 authorize-security-group-egress
  --group-id "$APP_TIER_SG"
  --protocol tcp
  --port 443
  --cidr 0.0.0.0/0

ii) Create an EC2 IAM role for Session Manager (step i): Allowed the application instances to reach SSM: Add the outbound rule of HTTP through NAT Gateways)

TCP 3306 → DATA_SG
TCP 443  → 0.0.0.0/0

a) Create the trust policy (policy file with Action as AssumeRole)

cat > ec2-ssm-trust-policy.json <<'EOF'

{

  "Version": "2012-10-17",

  "Statement": [

    {

    "Effect": "Allow",

    "Principal": {

    "Service": "ec2.amazonaws.com"

    },

    "Action": "sts:AssumeRole"

    }

  ]

}

EOF

b) Create the role

aws iam create-role
  --role-name ThreeTierEC2SSMRole
  --assume-role-policy-document file://ec2-ssm-trust-policy.json

c) Attach the AWS-managed SSM policy (AmazonSSMManagedInstanceCore provides the required System Manager permissions)

aws iam attach-role-policy
  --role-name ThreeTierEC2SSMRole
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

d) Create instance profile

aws iam create-instance-profile
  --instance-profile-name ThreeTierEC2SSMProfile

#Adding role to it

aws iam add-role-to-instance-profile
  --instance-profile-name ThreeTierEC2SSMProfile
  --role-name ThreeTierEC2SSMRole

#For IAM propagation, check whether your instances aready have another profile.

aws ec2 describe-instances
  --instance-ids "$INSTANCE_1" "$INSTANCE_2" "$INSTANCE_3"
  --query 'Reservations[].Instances[].[InstanceId,IamInstanceProfile.Arn]'
  --output table
  --no-cli-pager

#If IAM profile is empty then attach the new profile

for INSTANCE_ID in "$INSTANCE_1" "$INSTANCE_2" "$INSTANCE_3"; do
  aws ec2 associate-iam-instance-profile
    --instance-id "$INSTANCE_ID"
    --iam-instance-profile Name=ThreeTierEC2SSMProfile
done

e) Check whether the instances register with SSM

aws ssm describe-instance-information \

  --query 'InstanceInformationList[].[InstanceId,PingStatus,PlatformName,AgentVersion]' \

  --output table \

  --no-cli-pager

f) Connect to an instance

#EC2 → Instances → Select instance → Connect → Session Manager (Console)

#through CLI, Session Manager plugin has installed

aws ssm start-session
  --target "$INSTANCE_1"

Explaination

# Traditional architecture

Many beginners build this:

<pre class="overflow-visible! px-0!" data-start="1847" data-end="1910"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Internet
    │
    ▼
Public EC2
    │
SSH (22) open</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

Problems:

* SSH attacks
* Password guessing
* Key management
* Bastion hosts
* Open port 22

---

# Our architecture

Instead:

<pre class="overflow-visible! px-0!" data-start="2041" data-end="2177"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Internet
     │
     ▼
 ALB (Public)
     │
     ▼
Private EC2
     │
Outbound HTTPS (443)
     │
     ▼
AWS Systems Manager</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

Notice something:

The EC2 never accepts inbound SSH.

It only makes outbound HTTPS connections to AWS.

# How SSM actually works

This is the important concept.

When an EC2 boots:

<pre class="overflow-visible! px-0!" data-start="2367" data-end="2391"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>SSM Agent starts</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

The SSM Agent says:

> "Hello AWS,
>
> I'm Instance i-076d...
>
> I'm online."

It does this over HTTPS.

<pre class="overflow-visible! px-0!" data-start="2491" data-end="2541"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>EC2
 │
 │ HTTPS 443
 ▼
AWS Systems Manager</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

AWS remembers

<pre class="overflow-visible! px-0!" data-start="2558" data-end="2590"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Instance
Status = Online</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

---

Then from your laptop you run

<pre class="overflow-visible! px-0!" data-start="2628" data-end="2688"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ssm start-session \
    </span><span class="ͼn">--target</span><span> INSTANCE_ID</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

The request goes

<pre class="overflow-visible! px-0!" data-start="2708" data-end="2808"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Laptop
    │
    ▼
AWS Systems Manager
    │
    ▼
Existing HTTPS connection
    │
    ▼
EC2</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

Notice:

No SSH.

No public IP.

No inbound connection.

AWS simply tunnels your shell through the secure outbound connection already established by the SSM Agent.

# Why did we create the IAM Role?

Earlier we created

<pre class="overflow-visible! px-0!" data-start="3035" data-end="3062"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>ThreeTierEC2SSMRole</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

with

<pre class="overflow-visible! px-0!" data-start="3070" data-end="3106"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>AmazonSSMManagedInstanceCore</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

Why?

Because the EC2 instance must be authorized to communicate with Systems Manager.

Without that IAM role, the SSM Agent cannot register itself or accept session requests.

# Why did we open outbound port 443?

Originally your App SG allowed only:

<pre class="overflow-visible! px-0!" data-start="3366" data-end="3392"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>3306 → Database SG</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

That meant the EC2 could not reach AWS Systems Manager.

So we added:

<pre class="overflow-visible! px-0!" data-start="3465" data-end="3502"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>TCP 443
Destination 0.0.0.0/0</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

This allows secure outbound HTTPS to AWS services (through the NAT Gateway).

Without it:

<pre class="overflow-visible! px-0!" data-start="3595" data-end="3629"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>EC2
    X
Cannot reach SSM</span></code></pre></div></div></div></div></div></div></div></div></div></div></div></div></div></pre>

# Why didn't we open inbound port 22?

Because SSM doesn't need it.

Current inbound rules:

<pre class="overflow-visible! px-0!" data-start="3729" data-end="3769"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>ALB SG
    │
TCP 80
    ▼
APP SG</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

That's it.

No SSH.

No RDP.

No WinRM.

Much safer.

# Why did the ALB become unhealthy?

This was an excellent troubleshooting lesson.

Originally the Node.js server was started using:

<pre class="overflow-visible! px-0!" data-start="3964" data-end="3998"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>nohup </span><span class="ͼl">node</span><span> server.js &</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

That launches the process once.

However, after stopping and starting the EC2 instance:

<pre class="overflow-visible! px-0!" data-start="4089" data-end="4230"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>EC2 restarted

↓

Node process disappeared

↓

Nothing listening on port 80

↓

Health check failed

↓

ALB marked instance unhealthy</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

This explains why all three instances became unhealthy after the restart.

# Why did `systemd` solve the issue?

Instead of launching Node manually:

<pre class="overflow-visible! px-0!" data-start="4387" data-end="4400"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>nohup</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

we configured a `systemd` service.

Now the boot sequence is:

<pre class="overflow-visible! px-0!" data-start="4465" data-end="4583"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>EC2 boots
      │
      ▼
systemd starts
      │
      ▼
three-tier-app.service
      │
      ▼
Node.js starts</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

If Node crashes:

<pre class="overflow-visible! px-0!" data-start="4603" data-end="4687"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Node crashes
      │
      ▼
systemd notices
      │
      ▼
Starts it again</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

This is why `systemd` is the standard approach for long-running services on Linux.

# Why are the targets healthy now?

The ALB periodically sends:

<pre class="overflow-visible! px-0!" data-start="4843" data-end="4862"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>GET /health</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

to every registered EC2.

Your application returns:

<pre class="overflow-visible! px-0!" data-start="4917" data-end="4936"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>HTTP 200 OK</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

So the Target Group reports:

<pre class="overflow-visible! px-0!" data-start="4968" data-end="4992"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>Instance
Healthy</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

and the ALB includes that instance in load balancing.

# How all of this fits into the overall architecture

You have now completed the first two layers:

<pre class="overflow-visible! px-0!" data-start="5154" data-end="5565"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>               INTERNET
                    │
                    ▼
        Application Load Balancer
         (Presentation Tier)
                    │
     ┌──────────────┼──────────────┐
     ▼              ▼              ▼
 EC2-1          EC2-2          EC2-3
(Application Tier - Private Subnets)
                    │
                    ▼
            Database Tier
        (Private DB Subnets)</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

At the moment, the application ends at the EC2 instances because there is no database behind them yet.

==============================================================================================
5. Security Configuration (20%)

Security groups for each tier:
ALB SG: Allow 80/443 from 0.0.0.0/0
App SG: Allow 80/443 from ALB SG only
Data SG: Allow DB port from App SG only
Principle of least privilege applied
No direct internet access to private tiers

i) Check Data Tier Security group

aws ec2 describe-security-groups
  --group-ids "$DATA_TIER_SG"
  --query 'SecurityGroups[0].[GroupName,GroupId,IpPermissions,IpPermissionsEgress]'
  --output json
  --no-cli-pager

ii) Create the database placeholder script

# Part 2: Create the database placeholder script

The example from the other lab installs `nc` and runs an unmanaged background loop. We will use a better version:

* no package installation required;
* no internet access required;
* runs as a `systemd` service;
* automatically restarts after reboot;
* listens only on MySQL port `3306`.

Create the file on your laptop:

<pre class="overflow-visible! px-0!" data-start="2564" data-end="4435"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼl">cat</span><span> > db-userdata.sh </span><span class="ͼk"><<'EOF'</span><span>
</span><span class="ͼk">#!/bin/bash</span><span>
</span><span class="ͼk">set -e</span><span>

</span><span class="ͼk">cat > /opt/db-placeholder.py <<'PYTHON'</span><span>
</span><span class="ͼk">#!/usr/bin/env python3</span><span>

</span><span class="ͼk">import json</span><span>
</span><span class="ͼk">import socket</span><span>
</span><span class="ͼk">import threading</span><span>
</span><span class="ͼk">import time</span><span>

</span><span class="ͼk">HOST = "0.0.0.0"</span><span>
</span><span class="ͼk">PORT = 3306</span><span>
</span><span class="ͼk">START_TIME = time.time()</span><span>
</span><span class="ͼk">connection_count = 0</span><span>
</span><span class="ͼk">lock = threading.Lock()</span><span>


</span><span class="ͼk">def handle_client(connection, address):</span><span>
</span><span class="ͼk">    global connection_count</span><span>

</span><span class="ͼk">    with connection:</span><span>
</span><span class="ͼk">        with lock:</span><span>
</span><span class="ͼk">            connection_count += 1</span><span>
</span><span class="ͼk">            current_connections = connection_count</span><span>

</span><span class="ͼk">        response = {</span><span>
</span><span class="ͼk">            "status": "db_healthy",</span><span>
</span><span class="ͼk">            "service": "mysql-placeholder",</span><span>
</span><span class="ͼk">            "port": PORT,</span><span>
</span><span class="ͼk">            "client": address[0],</span><span>
</span><span class="ͼk">            "connections": current_connections,</span><span>
</span><span class="ͼk">            "uptime_seconds": round(time.time() - START_TIME, 2)</span><span>
</span><span class="ͼk">        }</span><span>

</span><span class="ͼk">        connection.sendall(</span><span>
</span><span class="ͼk">            (json.dumps(response) + "\n").encode("utf-8")</span><span>
</span><span class="ͼk">        )</span><span>


</span><span class="ͼk">def main():</span><span>
</span><span class="ͼk">    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)</span><span>
</span><span class="ͼk">    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)</span><span>
</span><span class="ͼk">    server.bind((HOST, PORT))</span><span>
</span><span class="ͼk">    server.listen(50)</span><span>

</span><span class="ͼk">    print(f"Database placeholder listening on {HOST}:{PORT}", flush=True)</span><span>

</span><span class="ͼk">    while True:</span><span>
</span><span class="ͼk">        connection, address = server.accept()</span><span>
</span><span class="ͼk">        thread = threading.Thread(</span><span>
</span><span class="ͼk">            target=handle_client,</span><span>
</span><span class="ͼk">            args=(connection, address),</span><span>
</span><span class="ͼk">            daemon=True</span><span>
</span><span class="ͼk">        )</span><span>
</span><span class="ͼk">        thread.start()</span><span>


</span><span class="ͼk">if __name__ == "__main__":</span><span>
</span><span class="ͼk">    main()</span><span>
</span><span class="ͼk">PYTHON</span><span>

</span><span class="ͼk">chmod +x /opt/db-placeholder.py</span><span>

</span><span class="ͼk">cat > /etc/systemd/system/db-placeholder.service <<'SERVICE'</span><span>
</span><span class="ͼk">[Unit]</span><span>
</span><span class="ͼk">Description=Three-Tier Database Placeholder</span><span>
</span><span class="ͼk">After=network-online.target</span><span>
</span><span class="ͼk">Wants=network-online.target</span><span>

</span><span class="ͼk">[Service]</span><span>
</span><span class="ͼk">Type=simple</span><span>
</span><span class="ͼk">ExecStart=/usr/bin/python3 /opt/db-placeholder.py</span><span>
</span><span class="ͼk">Restart=always</span><span>
</span><span class="ͼk">RestartSec=5</span><span>
</span><span class="ͼk">StandardOutput=journal</span><span>
</span><span class="ͼk">StandardError=journal</span><span>

</span><span class="ͼk">[Install]</span><span>
</span><span class="ͼk">WantedBy=multi-user.target</span><span>
</span><span class="ͼk">SERVICE</span><span>

</span><span class="ͼk">systemctl daemon-reload</span><span>
</span><span class="ͼk">systemctl enable --now db-placeholder.service</span><span>
</span><span class="ͼk">EOF</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Make it executable:

<pre class="overflow-visible! px-0!" data-start="4458" data-end="4493"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼl">chmod</span><span></span><span class="ͼg">+</span><span>x db-userdata.sh</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Validate the beginning:

<pre class="overflow-visible! px-0!" data-start="4520" data-end="4557"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>head </span><span class="ͼn">-n</span><span></span><span class="ͼj">10</span><span> db-userdata.sh</span></code></pre></div></div></div></div></div></div></div></div></div></div></div></div></div></div></pre>

ii) Confirm the AMI

# Part 3: Confirm the AMI

You previously exported:

<pre class="overflow-visible! px-0!" data-start="4617" data-end="4664"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">AMI_ID</span><span class="ͼg">=</span><span>ami-0b8dddb344dc74379</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Confirm it still exists:

<pre class="overflow-visible! px-0!" data-start="4692" data-end="4718"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼl">echo</span><span></span><span class="ͼk">"</span><span class="ͼm">$AMI_ID</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

You can also retrieve the current Amazon Linux 2023 AMI:

<pre class="overflow-visible! px-0!" data-start="4778" data-end="4957"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">AMI_ID</span><span class="ͼg">=</span><span>$(aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query </span><span class="ͼk">'Parameter.Value'</span><span> \
  --output text)</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Check:

<pre class="overflow-visible! px-0!" data-start="4967" data-end="4993"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼl">echo</span><span></span><span class="ͼk">"</span><span class="ͼm">$AMI_ID</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

iv) Launch the Database Tier instance

# Part 4: Launch the Database Tier instance

Use the first private database subnet:

<pre class="overflow-visible! px-0!" data-start="5085" data-end="5133"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">DB_SUBNET</span><span class="ͼg">=</span><span class="ͼk">"</span><span class="ͼm">$PRIVATE_SUBNET_3</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Launch the database placeholder:

<pre class="overflow-visible! px-0!" data-start="5169" data-end="5774"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">DB_INSTANCE</span><span class="ͼg">=</span><span>$(aws ec2 run-instances \
  --image-id </span><span class="ͼk">"</span><span class="ͼm">$AMI_ID</span><span class="ͼk">"</span><span> \
  --instance-type t3.micro \
  --security-group-ids </span><span class="ͼk">"</span><span class="ͼm">$DATA_TIER_SG</span><span class="ͼk">"</span><span> \
  --subnet-id </span><span class="ͼk">"</span><span class="ͼm">$DB_SUBNET</span><span class="ͼk">"</span><span> \
  --user-data file://db-userdata.sh \
  --metadata-options </span><span class="ͼk">"HttpTokens=required,HttpEndpoint=enabled"</span><span> \
  --tag-specifications \
  </span><span class="ͼk">'ResourceType=instance,Tags=[</span><span>
</span><span class="ͼk">    {Key=Name,Value=database-placeholder-1a},</span><span>
</span><span class="ͼk">    {Key=Tier,Value=data},</span><span>
</span><span class="ͼk">    {Key=Project,Value=three-tier-architecture},</span><span>
</span><span class="ͼk">    {Key=Environment,Value=development}</span><span>
</span><span class="ͼk">  ]'</span><span> \
  --query </span><span class="ͼk">'Instances[0].InstanceId'</span><span> \
  --output text)

</span><span class="ͼl">echo</span><span></span><span class="ͼk">"Database instance: </span><span class="ͼm">$DB_INSTANCE</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

You do not need:

* a public IP;
* a fixed private IP;
* port 22;
* a key pair;
* ALB registration.

The database is not an ALB target.

v) Wait for the databse instance

# Part 5: Wait for the database instance

<pre class="overflow-visible! px-0!" data-start="5960" data-end="6035"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ec2 wait instance-running \
  </span><span class="ͼn">--instance-ids</span><span></span><span class="ͼk">"</span><span class="ͼm">$DB_INSTANCE</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Then wait for EC2 status checks:

<pre class="overflow-visible! px-0!" data-start="6071" data-end="6148"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ec2 wait instance-status-ok \
  </span><span class="ͼn">--instance-ids</span><span></span><span class="ͼk">"</span><span class="ͼm">$DB_INSTANCE</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Display its details:

<pre class="overflow-visible! px-0!" data-start="6172" data-end="6463"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ec2 describe-instances \
  </span><span class="ͼn">--instance-ids</span><span></span><span class="ͼk">"</span><span class="ͼm">$DB_INSTANCE</span><span class="ͼk">"</span><span> \
  </span><span class="ͼn">--query</span><span></span><span class="ͼk">'Reservations[0].Instances[0].[</span><span>
</span><span class="ͼk">    InstanceId,</span><span>
</span><span class="ͼk">    State.Name,</span><span>
</span><span class="ͼk">    PrivateIpAddress,</span><span>
</span><span class="ͼk">    Placement.AvailabilityZone,</span><span>
</span><span class="ͼk">    SubnetId,</span><span>
</span><span class="ͼk">    SecurityGroups[0].GroupName</span><span>
</span><span class="ͼk">  ]'</span><span> \
  </span><span class="ͼn">--output</span><span> table \
  </span><span class="ͼn">--no-cli-pager</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Save its private IP:

<pre class="overflow-visible! px-0!" data-start="6487" data-end="6705"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">DB_PRIVATE_IP</span><span class="ͼg">=</span><span>$(aws ec2 describe-instances \
  --instance-ids </span><span class="ͼk">"</span><span class="ͼm">$DB_INSTANCE</span><span class="ͼk">"</span><span> \
  --query </span><span class="ͼk">'Reservations[0].Instances[0].PrivateIpAddress'</span><span> \
  --output text)

</span><span class="ͼl">echo</span><span></span><span class="ͼk">"Database private IP: </span><span class="ͼm">$DB_PRIVATE_IP</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

You should get an address belonging to your Database Tier subnet, for example:

<pre class="overflow-visible! px-0!" data-start="6787" data-end="6808"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>10.0.21.x</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

The exact address depends on your subnet CIDR.

vi) Verify tier isolation

# Part 6: Verify tier isolation

## Test from your laptop

Run:

<pre class="overflow-visible! px-0!" data-start="6928" data-end="7006"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>timeout </span><span class="ͼj">5</span><span></span><span class="ͼl">bash</span><span></span><span class="ͼn">-c</span><span></span><span class="ͼk">"cat < /dev/null > /dev/tcp/</span><span class="ͼm">$DB_PRIVATE_IP</span><span class="ͼk">/3306"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

This should fail or time out because:

* the database has no public IP;
* your laptop has no route to the VPC private IP;
* the Data SG accepts traffic only from `app-tier-sg`.

This is the correct result.

Do not use this as the only database test, because private IPs are not reachable directly from the public internet.

vii) Test from the App Tier instance

# Part 7: Test from an App Tier instance

Connect to an application instance:

<pre class="overflow-visible! px-0!" data-start="7416" data-end="7476"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ssm start-session \
  </span><span class="ͼn">--target</span><span></span><span class="ͼk">"</span><span class="ͼm">$INSTANCE_1</span><span class="ͼk">"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Your local `DB_PRIVATE_IP` variable will not automatically exist inside the SSM shell. Copy the database IP shown earlier and set it inside the instance:

<pre class="overflow-visible! px-0!" data-start="7633" data-end="7698"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">export</span><span></span><span class="ͼm">DB_PRIVATE_IP</span><span class="ͼg">=</span><span class="ͼk">"PASTE_DATABASE_PRIVATE_IP_HERE"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Test TCP port `3306`:

<pre class="overflow-visible! px-0!" data-start="7723" data-end="7911"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>timeout </span><span class="ͼj">5</span><span></span><span class="ͼl">bash</span><span></span><span class="ͼn">-c</span><span></span><span class="ͼk">"cat < /dev/null > /dev/tcp/</span><span class="ͼm">$DB_PRIVATE_IP</span><span class="ͼk">/3306"</span><span> \
  && </span><span class="ͼl">echo</span><span></span><span class="ͼk">"SUCCESS: App Tier can reach Database Tier"</span><span> \
  || </span><span class="ͼl">echo</span><span></span><span class="ͼk">"FAILED: Database connection unavailable"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

To read the placeholder response:

<pre class="overflow-visible! px-0!" data-start="7948" data-end="8014"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>timeout </span><span class="ͼj">5</span><span></span><span class="ͼl">bash</span><span></span><span class="ͼn">-c</span><span></span><span class="ͼk">"cat < /dev/tcp/</span><span class="ͼm">$DB_PRIVATE_IP</span><span class="ͼk">/3306"</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

Expected output:

<pre class="overflow-visible! px-0!" data-start="8034" data-end="8169"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>{
  "status": </span><span class="ͼk">"db_healthy"</span><span>,
  "service": </span><span class="ͼk">"mysql-placeholder"</span><span>,
  "port": </span><span class="ͼj">3306</span><span>,
  "client": </span><span class="ͼk">"10.0.11.x"</span><span>,
  "connections": </span><span class="ͼj">1</span><span>
}</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

This proves:

<pre class="overflow-visible! px-0!" data-start="8185" data-end="8238"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute end-1.5 top-1 z-2 md:end-2 md:top-1"></div><div class="relative"><div class="pe-11 pt-3"><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>App EC2 → TCP 3306 → Database placeholder</span></code></pre></div></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></pre>

Exit the SSM session:

<pre class="overflow-visible! px-0!" data-start="8263" data-end="8279"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span class="ͼg">exit</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

viii) Verify the correct security groups

# Part 8: Verify the correct security groups

Run from your laptop:

<pre class="overflow-visible! px-0!" data-start="8355" data-end="8626"><div class="relative w-full mt-4 mb-1"><div class=""><div class="contents"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="relative h-full w-full border-radius-3xl bg-(--code-block-surface) corner-superellipse/1.1 overflow-clip rounded-3xl [--code-block-surface:var(--bg-elevated-secondary)] dark:[--code-block-surface:var(--composer-surface-primary)] lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class=""><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼd ͼr"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>aws ec2 describe-security-groups \
  </span><span class="ͼn">--group-ids</span><span></span><span class="ͼk">"</span><span class="ͼm">$ALB_SG</span><span class="ͼk">"</span><span></span><span class="ͼk">"</span><span class="ͼm">$APP_TIER_SG</span><span class="ͼk">"</span><span></span><span class="ͼk">"</span><span class="ͼm">$DATA_TIER_SG</span><span class="ͼk">"</span><span> \
  </span><span class="ͼn">--query</span><span></span><span class="ͼk">'SecurityGroups[].{</span><span>
</span><span class="ͼk">    Name:GroupName,</span><span>
</span><span class="ͼk">    ID:GroupId,</span><span>
</span><span class="ͼk">    Inbound:IpPermissions,</span><span>
</span><span class="ͼk">    Outbound:IpPermissionsEgress</span><span>
</span><span class="ͼk">  }'</span><span> \
  </span><span class="ͼn">--output</span><span> json \
  </span><span class="ͼn">--no-cli-pager</span></code></pre></div></div></div></div></div></div></div></div><div class=""><div class=""></div></div></div></div></div></div></div></div></pre>

The intended flow is:

| Tier        | Allowed inbound traffic   |
| ----------- | ------------------------- |
| ALB         | TCP 80 from internet      |
| Application | TCP 80 from ALB SG        |
| Database    | TCP 3306 from App Tier SG |

This is called  **security-group referencing** . It is better than allowing entire CIDR ranges because access depends on the source security group, not on manually managed IP addresses.

=============================================================================================
6. Documentation (10%)

Architecture diagram (clear and professional)
README with:
Architecture overview
Design decisions and trade-offs
Security strategy
Testing results
Cost breakdown
Should Have (Recommended - 15%)
Multi-AZ NAT Gateway (high availability)
Auto Scaling Group for application tier
RDS Multi-AZ database
HTTPS listener with ACM certificate
CloudWatch alarms for monitoring
Centralized session storage (ElastiCache)
VPC Flow Logs enabled
Cost allocation tags
