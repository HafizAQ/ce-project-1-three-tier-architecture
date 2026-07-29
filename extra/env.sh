##AWS Region 
export AWS_REGION=us-east-1

#### VPC Name: three-tier-project-vpc (/16 CIDR block)
export VPC_ID=vpc-0b8abdf55187111a2


#### 6 Subnets across 2 Availability Zones (AZs)
###Presentation Tier: Public 
#pre-public-subnet-1a
export PUBLIC_SUBNET_1=subnet-0f295f17f700b934b
#pre-public-subnet-1b
export PUBLIC_SUBNET_2=subnet-088aa13cf8a99827a

###Application Tier: Private 
#app-private-subnet-1a
export PRIVATE_SUBNET_1=subnet-02b228abe41ff4c61
#app-private-subnet-1b
export PRIVATE_SUBNET_2=subnet-0b486dd9009edd6ea

###Database Tier: Private 
#db-private-subnet-1a
export PRIVATE_SUBNET_3=subnet-0617d44e5b84b332b
#db-private-subnet-1b
export PRIVATE_SUBNET_4=subnet-0c1759b9ec7ac11f9


#################################################
###Elastic IP (for NAT Gateways)
#three-tier-nat-gateway-1a-eip
export EIP_ALLOC_1a=eipalloc-05f7aa8cbc534b8a0
#three-tier-nat-gateway-1b-eip
export EIP_ALLOC_1b=eipalloc-0395cf6d0d0addbf7

###NAT gateways in two AZs (A and B) for private subnet outbound traffic 
#three-tier-nat-1a-gw
export NAT_GW_1a=nat-01a042676289ef3dd
#three-tier-nat-1b-gw
export NAT_GW_1b=nat-0910633345378aa19

###IGW (Internet gateway) attached to VPC: three-tier-igw
export IGW_ID=igw-04ca84f98d437db94

####################################
#### Route Tables 
#pre-public-rt: Route table for two public subnets of Presentation tier in two AZs (A and B)
export PUBLIC_RT=rtb-0ac2e4856b98121aa
#app-rt-1a: Route table for a private subnet of Application tier in AZ-A
export APP_RT_1=rtb-0a1f09deb74009412
#app-rt-1b: Route table for a private subnet of Application tier in AZ-B
export APP_RT_2=rtb-044e9601b97492269
#db-rt: Rout table for two private subnets of the Database tier in two AZs (A and B)
export DB_RT=rtb-02f43244b02c841b9

######################################
# Preparing userdata.sh 
# ALB_SG: Application Load Balancer Security Group (internet facing) 
# export ALB_SG=sg-03b672bea8bfb5eee

# WEB_SG: Web Server Security Group 
# export WEB_SG=sg-0d9683c972aba4863

# Retieve the Latest Amazon Linux 2023 AMI
export AMI_ID=ami-0b8dddb344dc74379



#Launch 3 EC2 Instance, placing  
###################################
#web-server-1a: AZ 1a
export INSTANCE_1=i-076d7676f4e0a3122
#web-server-1a-2: AZ 1a 2
export INSTANCE_2=i-0f666c34abcfc4270
#web-server-1b: AZ 1b
export INSTANCE_3=i-0a1469632365a6a42

### web-servers-tg : Target Group for forwarding HTTP traffic to the EC2 instances on port 80
export TG_ARN=arn:aws:elasticloadbalancing:us-east-1:203637464233:targetgroup/web-servers-tg/8d18a51ea4a8a16b

### register the EC2 instances and check health/ target health (elbv: ellastic load balancing v2)

###Create the Application Load Balancer 
export ALB_ARN=arn:aws:elasticloadbalancing:us-east-1:203637464233:loadbalancer/app/web-alb/08da134c689899fe
### Retieve the ALB DNS name 
export ALB_DNS=web-alb-1665614039.us-east-1.elb.amazonaws.com

####Listener: Accepting HTTP traffic on port 80 and forwarding it to the target group
export LISTENER_ARN=arn:aws:elasticloadbalancing:us-east-1:203637464233:listener/app/web-alb/08da134c689899fe/0d59cb416783b90a


#Security Group 
#1. alb-sg         → Allow 80,443 from 0.0.0.0/0
#2. app-tier-sg    → Allow 80,443 from alb-sg
#3. data-tier-sg   → Allow 3306/5432 from app-tier-sg only

#1. alb-sg         
export ALB_SG=sg-03b672bea8bfb5eee
#2. app-tier-sg
export APP_TIER_SG=sg-03e745f582cea2f21
#3. data-tier-sg   
export DATA_TIER_SG=sg-097b91305f3504c9f
# export DB_SG=$DATA_TIER_SG

# export APP_TIER_SG=$WEB_SG

# export APP_TIER_SG=sg-0d9683c972aba4863
###################################################################
# Database Tier instance

#Private subnet 3 is now our DB subnet 
export DB_SUBNET="$PRIVATE_SUBNET_3"

#Lauched DB instance at AZ 1a: database-placeholder-1a 
export DB_INSTANCE=i-091f5b34ca45fc8ec

#Database Private IP
export DB_PRIVATE_IP=10.0.31.199

# Attach the existing profile
# aws ec2 associate-iam-instance-profile \
#   --instance-id "$DB_INSTANCE" \
#   --iam-instance-profile Name=ThreeTierEC2SSMProfile


#####Every new booting instances give the DB_RT to NAT_GW_1a to be visible for AWS SSM (Session Manager)
# aws ec2 create-route \
#   --route-table-id "$DB_RT" \
#   --destination-cidr-block 0.0.0.0/0 \
#   --nat-gateway-id "$NAT_GW_1a" \
#   --no-cli-pager

############ Run 
#aws ssm start-session --target "$DB_INSTANCE"

