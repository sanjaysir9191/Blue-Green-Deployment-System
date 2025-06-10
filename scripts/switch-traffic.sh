# # # ==============================================
# # # FILE: scripts/switch-traffic.sh
# # # ==============================================
# # #!/bin/bash
# # set -e

# # TARGET_ENVIRONMENT=$1

# # if [ -z "$TARGET_ENVIRONMENT" ]; then
# #     echo "Usage: $0 <blue|green>"
# #     exit 1
# # fi

# # # Get target group ARN based on environment
# # if [ "$TARGET_ENVIRONMENT" = "blue" ]; then
# #     TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw blue_target_group_arn)
# # else
# #     TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw green_target_group_arn)
# # fi

# # echo "Switching traffic to $TARGET_ENVIRONMENT environment..."

# # # Update ALB listener to point to new target group
# # aws elbv2 modify-listener \
# #     --listener-arn $(aws elbv2 describe-listeners \
# #         --load-balancer-arn $(terraform -chdir=infrastructure output -raw alb_arn) \
# #         --query 'Listeners[0].ListenerArn' --output text) \
# #     --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# # echo "Traffic successfully switched to $TARGET_ENVIRONMENT!"
# #!/bin/bash



# #!/bin/bash

# set -e

# TARGET_ENVIRONMENT=$1

# if [ -z "$TARGET_ENVIRONMENT" ]; then
#     echo "Usage: $0 <blue|green>"
#     exit 1
# fi

# # Validate environment parameter
# if [ "$TARGET_ENVIRONMENT" != "blue" ] && [ "$TARGET_ENVIRONMENT" != "green" ]; then
#     echo "Error: TARGET_ENVIRONMENT must be either 'blue' or 'green'"
#     exit 1
# fi

# echo "Switching traffic to $TARGET_ENVIRONMENT environment..."

# # Validate Terraform outputs exist
# echo "Validating Terraform outputs..."
# terraform -chdir=infrastructure output >/dev/null 2>&1 || {
#     echo "Error: Cannot read Terraform outputs. Make sure you're in the correct directory and Terraform has been applied."
#     exit 1
# }

# # Get target group ARN based on environment
# echo "Getting target group ARN for $TARGET_ENVIRONMENT..."
# if [ "$TARGET_ENVIRONMENT" = "blue" ]; then
#     TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw blue_target_group_arn)
# else
#     TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw green_target_group_arn)
# fi

# if [ -z "$TARGET_GROUP_ARN" ]; then
#     echo "Error: Could not retrieve target group ARN for $TARGET_ENVIRONMENT"
#     echo "Available Terraform outputs:"
#     terraform -chdir=infrastructure output
#     exit 1
# fi

# echo "Target group ARN: $TARGET_GROUP_ARN"

# # Get ALB ARN from Terraform output
# echo "Getting ALB ARN..."
# ALB_ARN=$(terraform -chdir=infrastructure output -raw alb_arn)

# if [ -z "$ALB_ARN" ]; then
#     echo "Error: Could not retrieve ALB ARN from Terraform output"
#     echo "Available Terraform outputs:"
#     terraform -chdir=infrastructure output
#     exit 1
# fi

# echo "ALB ARN: $ALB_ARN"

# # Validate ALB exists and is accessible
# echo "Validating ALB accessibility..."
# ALB_STATE=$(aws elbv2 describe-load-balancers \
#     --load-balancer-arns "$ALB_ARN" \
#     --query 'LoadBalancers[0].State.Code' \
#     --output text 2>/dev/null || echo "error")

# if [ "$ALB_STATE" != "active" ]; then
#     echo "Error: ALB is not active or not accessible. State: $ALB_STATE"
#     echo "Please check if the ALB exists and your AWS credentials are correct."
    
#     # Show ALB DNS name for reference
#     ALB_DNS=$(terraform -chdir=infrastructure output -raw alb_dns_name 2>/dev/null || echo "unavailable")
#     echo "Expected ALB DNS name: $ALB_DNS"
#     exit 1
# fi

# echo "ALB is active and accessible"

# # Get listener ARN
# echo "Getting listener ARN..."
# LISTENER_ARN=$(aws elbv2 describe-listeners \
#     --load-balancer-arn "$ALB_ARN" \
#     --query 'Listeners[0].ListenerArn' \
#     --output text)

# if [ -z "$LISTENER_ARN" ] || [ "$LISTENER_ARN" = "None" ]; then
#     echo "Error: Could not retrieve listener ARN"
#     exit 1
# fi

# echo "Listener ARN: $LISTENER_ARN"

# # Show current configuration before change
# echo "Getting current listener configuration..."
# CURRENT_TARGET_GROUP=$(aws elbv2 describe-listeners \
#     --listener-arns "$LISTENER_ARN" \
#     --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
#     --output text)

# if [ "$CURRENT_TARGET_GROUP" = "$TARGET_GROUP_ARN" ]; then
#     echo "Traffic is already pointing to $TARGET_ENVIRONMENT target group"
#     echo "Current target group: $CURRENT_TARGET_GROUP"
#     echo "No changes needed!"
#     exit 0
# fi

# echo "Currently pointing to: $CURRENT_TARGET_GROUP"
# echo "Will switch to: $TARGET_GROUP_ARN"

# # Update ALB listener to point to new target group
# echo "Updating listener to point to $TARGET_ENVIRONMENT target group..."
# aws elbv2 modify-listener \
#     --listener-arn "$LISTENER_ARN" \
#     --default-actions Type=forward,TargetGroupArn="$TARGET_GROUP_ARN"

# if [ $? -eq 0 ]; then
#     echo "✅ Traffic successfully switched to $TARGET_ENVIRONMENT!"
# else
#     echo "❌ Failed to switch traffic"
#     exit 1
# fi

# # Verify the change
# echo "Verifying the change..."
# sleep 2  # Give AWS a moment to update
# NEW_TARGET_GROUP=$(aws elbv2 describe-listeners \
#     --listener-arns "$LISTENER_ARN" \
#     --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
#     --output text)

# if [ "$NEW_TARGET_GROUP" = "$TARGET_GROUP_ARN" ]; then
#     echo "✅ Verification successful - listener now points to $TARGET_ENVIRONMENT environment"
    
#     # Show ALB DNS name for testing
#     ALB_DNS=$(terraform -chdir=infrastructure output -raw alb_dns_name)
#     echo "📋 You can test your application at: http://$ALB_DNS"
# else
#     echo "❌ Verification failed - listener points to: $NEW_TARGET_GROUP"
#     echo "Expected: $TARGET_GROUP_ARN"
#     exit 1
# fi


#!/bin/bash

set -e

TARGET_ENVIRONMENT=$1

if [ -z "$TARGET_ENVIRONMENT" ]; then
    echo "Usage: $0 <blue|green>"
    exit 1
fi

# Validate environment parameter
if [ "$TARGET_ENVIRONMENT" != "blue" ] && [ "$TARGET_ENVIRONMENT" != "green" ]; then
    echo "Error: TARGET_ENVIRONMENT must be either 'blue' or 'green'"
    exit 1
fi

echo "Switching traffic to $TARGET_ENVIRONMENT environment..."

# Validate Terraform outputs exist
echo "Validating Terraform outputs..."
terraform -chdir=infrastructure output >/dev/null 2>&1 || {
    echo "Error: Cannot read Terraform outputs. Make sure you're in the correct directory and Terraform has been applied."
    exit 1
}

# Get target group ARN based on environment
echo "Getting target group ARN for $TARGET_ENVIRONMENT..."
if [ "$TARGET_ENVIRONMENT" = "blue" ]; then
    TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw blue_target_group_arn)
else
    TARGET_GROUP_ARN=$(terraform -chdir=infrastructure output -raw green_target_group_arn)
fi

if [ -z "$TARGET_GROUP_ARN" ]; then
    echo "Error: Could not retrieve target group ARN for $TARGET_ENVIRONMENT"
    echo "Available Terraform outputs:"
    terraform -chdir=infrastructure output
    exit 1
fi

echo "Target group ARN: $TARGET_GROUP_ARN"

# Get ALB ARN from Terraform output
echo "Getting ALB ARN..."
ALB_ARN=$(terraform -chdir=infrastructure output -raw alb_arn)

if [ -z "$ALB_ARN" ]; then
    echo "Error: Could not retrieve ALB ARN from Terraform output"
    echo "Available Terraform outputs:"
    terraform -chdir=infrastructure output
    exit 1
fi

echo "ALB ARN: $ALB_ARN"

# Validate ALB exists and is accessible
echo "Validating ALB accessibility..."
ALB_STATE=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns "$ALB_ARN" \
    --query 'LoadBalancers[0].State.Code' \
    --output text 2>/dev/null || echo "error")

if [ "$ALB_STATE" != "active" ]; then
    echo "Error: ALB is not active or not accessible. State: $ALB_STATE"
    echo "Please check if the ALB exists and your AWS credentials are correct."
    
    # Show ALB DNS name for reference
    ALB_DNS=$(terraform -chdir=infrastructure output -raw alb_dns_name 2>/dev/null || echo "unavailable")
    echo "Expected ALB DNS name: $ALB_DNS"
    exit 1
fi

echo "ALB is active and accessible"

# Get listener ARN
echo "Getting listener ARN..."
LISTENER_ARN=$(aws elbv2 describe-listeners \
    --load-balancer-arn "$ALB_ARN" \
    --query 'Listeners[0].ListenerArn' \
    --output text)

if [ -z "$LISTENER_ARN" ] || [ "$LISTENER_ARN" = "None" ]; then
    echo "Error: Could not retrieve listener ARN"
    exit 1
fi

echo "Listener ARN: $LISTENER_ARN"

# Show current configuration before change
echo "Getting current listener configuration..."
CURRENT_TARGET_GROUP=$(aws elbv2 describe-listeners \
    --listener-arns "$LISTENER_ARN" \
    --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
    --output text)

if [ "$CURRENT_TARGET_GROUP" = "$TARGET_GROUP_ARN" ]; then
    echo "Traffic is already pointing to $TARGET_ENVIRONMENT target group"
    echo "Current target group: $CURRENT_TARGET_GROUP"
    echo "No changes needed!"
    exit 0
fi

echo "Currently pointing to: $CURRENT_TARGET_GROUP"
echo "Will switch to: $TARGET_GROUP_ARN"

# Update ALB listener to point to new target group
echo "Updating listener to point to $TARGET_ENVIRONMENT target group..."
aws elbv2 modify-listener \
    --listener-arn "$LISTENER_ARN" \
    --default-actions Type=forward,TargetGroupArn="$TARGET_GROUP_ARN"

if [ $? -eq 0 ]; then
    echo "✅ Traffic successfully switched to $TARGET_ENVIRONMENT!"
else
    echo "❌ Failed to switch traffic"
    exit 1
fi

# Verify the change
echo "Verifying the change..."
sleep 2  # Give AWS a moment to update
NEW_TARGET_GROUP=$(aws elbv2 describe-listeners \
    --listener-arns "$LISTENER_ARN" \
    --query 'Listeners[0].DefaultActions[0].TargetGroupArn' \
    --output text)

if [ "$NEW_TARGET_GROUP" = "$TARGET_GROUP_ARN" ]; then
    echo "✅ Verification successful - listener now points to $TARGET_ENVIRONMENT environment"
    
    # Show ALB DNS name for testing
    ALB_DNS=$(terraform -chdir=infrastructure output -raw alb_dns_name)
    echo "📋 You can test your application at: http://$ALB_DNS"
else
    echo "❌ Verification failed - listener points to: $NEW_TARGET_GROUP"
    echo "Expected: $TARGET_GROUP_ARN"
    exit 1
fi