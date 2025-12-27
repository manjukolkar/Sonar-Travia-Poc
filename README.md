# CI/CD POC with Git, Jenkins, Docker, SonarQube, and Trivy

This POC demonstrates a complete CI/CD pipeline integration with code quality and security scanning on AWS EC2.

## Architecture Overview

- **AWS EC2**: Amazon Linux 2 instance hosting all tools
- **Git**: Version control
- **Jenkins**: CI/CD automation
- **Docker**: Containerization
- **SonarQube**: Code quality analysis
- **Trivy**: Security vulnerability scanning
- **Python Flask App**: Simple landing page application

## Prerequisites

- AWS Account
- SSH access to EC2 instance
- Basic knowledge of AWS Console

## AWS Setup Instructions (via UI)

### Step 1: Launch EC2 Instance

1. Log in to AWS Console
2. Navigate to **EC2** service
3. Click **Launch Instance**
4. Configure the instance:
   - **Name**: `ci-cd-poc-instance`
   - **AMI**: Amazon Linux 2023 (or Amazon Linux 2)
   - **Instance Type**: `t3.medium` (minimum recommended for SonarQube)
   - **Key Pair**: Create or select an existing key pair
   - **Network Settings**: 
     - Create new security group or use existing
     - Add inbound rules:
       - SSH (22) from your IP
       - HTTP (80) from anywhere (0.0.0.0/0)
       - HTTPS (443) from anywhere (0.0.0.0/0)
       - Custom TCP (8080) from anywhere (for Jenkins)
       - Custom TCP (9000) from anywhere (for SonarQube)
   - **Storage**: 20 GB minimum (recommended: 30 GB)
   - **Advanced Details**: 
     - User data: Leave empty (we'll run installation script manually)
5. Click **Launch Instance**

### Step 2: Configure Security Group

1. Go to **Security Groups** in EC2 console
2. Select your instance's security group
3. Edit inbound rules and ensure:
   - Port 22 (SSH)
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
   - Port 8080 (Jenkins)
   - Port 9000 (SonarQube)

### Step 3: Allocate Elastic IP (Optional but Recommended)

1. Go to **Elastic IPs** in EC2 console
2. Click **Allocate Elastic IP address**
3. Select your instance and click **Associate Elastic IP address**

## Installation Steps

### Step 1: Connect to EC2 Instance

```bash
ssh -i your-key.pem ec2-user@<your-ec2-ip>
```

### Step 2: Clone Repository

```bash
git clone <your-repo-url>
cd sonar-poc
```

### Step 3: Run Installation Script

```bash
chmod +x scripts/install-all-tools.sh
sudo ./scripts/install-all-tools.sh
```

This script will install:
- Git
- Docker
- Docker Compose
- Jenkins
- SonarQube
- Trivy
- Python 3 and pip
- Required dependencies

### Step 4: Start Services

```bash
# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Start SonarQube (via Docker)
cd docker
docker-compose up -d
```

### Step 5: Access Services

- **Jenkins**: http://your-ec2-ip:8080
  - Initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- **SonarQube**: http://your-ec2-ip:9000
  - Default credentials: admin/admin (change on first login)
- **Application**: http://your-ec2-ip:5000

## Project Structure

```
sonar-poc/
├── README.md
├── .gitignore
├── scripts/
│   └── install-all-tools.sh
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── templates/
│   │   └── index.html
│   └── static/
│       └── style.css
├── jenkins/
│   └── Jenkinsfile
├── docker/
│   ├── docker-compose.yml
│   └── Dockerfile
├── sonar/
│   └── sonar-project.properties
└── .trivyignore
```

## Jenkins Pipeline

The Jenkins pipeline (`jenkins/Jenkinsfile`) performs:
1. Checkout code from Git
2. Build Docker image
3. Run Trivy security scan
4. Run SonarQube analysis
5. Deploy application

## Usage

### Running the Application Locally

```bash
cd app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

### Running Code Quality Checks

```bash
# SonarQube scan
sonar-scanner

# Trivy scan
trivy image <image-name>
```

## Notes

- Ensure EC2 instance has sufficient resources (minimum 2GB RAM, 2 vCPU)
- SonarQube requires significant memory; adjust Docker resources if needed
- All services run on the same EC2 instance for POC purposes
- For production, consider separating services across multiple instances

## Troubleshooting

- If Jenkins doesn't start: Check logs with `sudo journalctl -u jenkins`
- If SonarQube doesn't start: Check Docker logs with `docker-compose logs sonarqube`
- If ports are not accessible: Verify security group rules in AWS Console

