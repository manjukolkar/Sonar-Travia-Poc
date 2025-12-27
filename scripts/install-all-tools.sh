#!/bin/bash

# CI/CD POC - Installation Script for Amazon Linux
# This script installs Git, Jenkins, Docker, SonarQube, and Trivy

set -e

echo "========================================="
echo "Starting CI/CD Tools Installation"
echo "========================================="

# Update system
echo "Updating system packages..."
sudo yum update -y

# Install Git
echo "Installing Git..."
sudo yum install -y git
git --version

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Install Java (required for Jenkins and SonarQube)
echo "Installing Java..."
sudo yum install -y java-17-amazon-corretto-devel
java -version

# Install Jenkins
echo "Installing Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Python 3 and pip
echo "Installing Python 3..."
sudo yum install -y python3 python3-pip
python3 --version
pip3 --version

# Install Trivy
echo "Installing Trivy..."
sudo yum install -y wget
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -qO- "https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz" | sudo tar -xz -C /usr/local/bin/ trivy
sudo chmod +x /usr/local/bin/trivy
trivy --version

# Install SonarQube Scanner
echo "Installing SonarQube Scanner..."
cd /tmp
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo yum install -y unzip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip -d /opt
sudo mv /opt/sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner
sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile
rm sonar-scanner-cli-5.0.1.3006-linux.zip

# Install additional tools
echo "Installing additional tools..."
sudo yum install -y curl wget unzip

# Configure Docker to start on boot
echo "Configuring Docker..."
sudo systemctl daemon-reload

# Display installation summary
echo "========================================="
echo "Installation Summary"
echo "========================================="
echo "Git version: $(git --version)"
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"
echo "Java version: $(java -version 2>&1 | head -n 1)"
echo "Jenkins: $(sudo systemctl is-active jenkins)"
echo "Python version: $(python3 --version)"
echo "Trivy version: $(trivy --version)"
echo "SonarQube Scanner: $(sonar-scanner --version 2>&1 | head -n 1)"

echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Get Jenkins initial admin password:"
echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "2. Start SonarQube:"
echo "   cd docker && docker-compose up -d"
echo ""
echo "3. Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "4. Access SonarQube at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo ""
echo "Note: You may need to log out and log back in for Docker group changes to take effect."

