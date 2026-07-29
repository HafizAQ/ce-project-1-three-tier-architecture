#!/usr/bin/env bash

set -euo pipefail

: "${AWS_REGION:?AWS_REGION is required}"
: "${DB_PRIVATE_IP:?DB_PRIVATE_IP is required}"
: "${INSTANCE_1:?INSTANCE_1 is required}"
: "${INSTANCE_2:?INSTANCE_2 is required}"
: "${INSTANCE_3:?INSTANCE_3 is required}"

APP_FILE="app/server.js"

if [[ ! -f "$APP_FILE" ]]; then
  echo "ERROR: $APP_FILE was not found."
  exit 1
fi

APP_BASE64=$(base64 -w 0 "$APP_FILE")
INSTANCE_IDS=("$INSTANCE_1" "$INSTANCE_2" "$INSTANCE_3")

for INSTANCE_ID in "${INSTANCE_IDS[@]}"; do
  echo "Deploying application to $INSTANCE_ID..."

  COMMAND_ID=$(aws ssm send-command \
    --region "$AWS_REGION" \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --comment "Deploy three-tier Node.js application" \
    --parameters "commands=[
      \"echo '$APP_BASE64' | base64 -d > /home/ec2-user/server.js\",
      \"chown ec2-user:ec2-user /home/ec2-user/server.js\",
      \"chmod 0644 /home/ec2-user/server.js\",
      \"mkdir -p /etc/systemd/system/three-tier-app.service.d\",
      \"printf '[Service]\\nEnvironment=DB_HOST=$DB_PRIVATE_IP\\nEnvironment=DB_PORT=3306\\n' > /etc/systemd/system/three-tier-app.service.d/database.conf\",
      \"systemctl daemon-reload\",
      \"systemctl enable three-tier-app\",
      \"systemctl restart three-tier-app\",
      \"systemctl is-active three-tier-app\",
      \"sleep 3\",
      \"curl --retry 10 --retry-delay 2 --retry-connrefused -fsS http://localhost/health\",
      \"curl --retry 5 --retry-delay 2 --retry-connrefused -fsS http://localhost/api/stats\"
    ]" \
    --query 'Command.CommandId' \
    --output text)

  echo "Command ID: $COMMAND_ID"

  if ! aws ssm wait command-executed \
    --region "$AWS_REGION" \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID"; then

    echo "Deployment command failed on $INSTANCE_ID."

    aws ssm get-command-invocation \
      --region "$AWS_REGION" \
      --command-id "$COMMAND_ID" \
      --instance-id "$INSTANCE_ID" \
      --query '{
        Status:Status,
        ResponseCode:ResponseCode,
        StandardOutput:StandardOutputContent,
        StandardError:StandardErrorContent
      }' \
      --output json \
      --no-cli-pager

    exit 1
  fi

  aws ssm get-command-invocation \
    --region "$AWS_REGION" \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --query '{
      Status:Status,
      ResponseCode:ResponseCode,
      StandardOutput:StandardOutputContent,
      StandardError:StandardErrorContent
    }' \
    --output json \
    --no-cli-pager

  echo "Deployment successful on $INSTANCE_ID."
  echo
done

echo "Deployment completed on all application instances."
