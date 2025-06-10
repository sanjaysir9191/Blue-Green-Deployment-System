# # ==============================================
# # FILE: infrastructure/user-data.sh
# # ==============================================
# #!/bin/bash
# yum update -y
# yum install -y docker
# systemctl start docker
# systemctl enable docker
# usermod -a -G docker ec2-user

# # Install Docker Compose
# curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

# # Install AWS CLI
# yum install -y awscli

# # Environment setup
# echo "ENVIRONMENT=${environment}" > /home/ec2-user/.env



#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI
yum install -y awscli

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 975728335652.dkr.ecr.us-east-1.amazonaws.com

# Pull the app image
docker pull 975728335652.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Run container
if [ "$${environment}" == "blue" ]; then
  PORT=8080
else
  PORT=8081
fi

docker run -d -p $$PORT:$$PORT \
  -e ENVIRONMENT=$${environment} \
  -e PORT=$$PORT \
  975728335652.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
