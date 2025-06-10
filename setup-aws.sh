# ==============================================
# FILE: setup-aws.sh
# ==============================================
#!/bin/bash
set -e

echo "Setting up Blue-Green Deployment Environment..."

# Install required tools
sudo apt update -y
#sudo apt  install -y git docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $USER

# Install Docker Compose
#sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose

# Install Terraform
#wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
#unzip terraform_1.5.0_linux_amd64.zip
#sudo mv terraform /usr/local/bin/
#rm terraform_1.5.0_linux_amd64.zip

# Configure AWS CLI (user will need to provide credentials)
#echo "Please configure AWS CLI with your credentials:"
#aws configure

echo "Setup complete! You can now run 'terraform init' in the infrastructure directory."