# Jenkins Setup Guide

This guide will help you configure Jenkins for the CI/CD pipeline.

## Initial Jenkins Setup

1. **Access Jenkins**
   - Open browser: `http://<your-ec2-ip>:8080`
   - Get initial admin password:
     ```bash
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
     ```

2. **Install Suggested Plugins**
   - On first login, select "Install suggested plugins"
   - Wait for installation to complete

3. **Create Admin User**
   - Fill in the admin user form
   - Save and continue

## Required Jenkins Plugins

Install the following plugins via **Manage Jenkins > Plugins**:

1. **Pipeline** (usually pre-installed)
2. **Docker Pipeline**
3. **SonarQube Scanner**
4. **Git** (usually pre-installed)
5. **Credentials Binding**

## Configure SonarQube in Jenkins

1. **Get SonarQube Token**
   - Access SonarQube: `http://<your-ec2-ip>:9000`
   - Login with default credentials: `admin/admin`
   - Go to **My Account > Security**
   - Generate a new token (e.g., `jenkins-token`)
   - Copy the token

2. **Add SonarQube Server in Jenkins**
   - Go to **Manage Jenkins > Configure System**
   - Scroll to **SonarQube servers**
   - Click **Add SonarQube**
   - Name: `SonarQube`
   - Server URL: `http://localhost:9000`
   - Server authentication token: Click **Add** to create new token
     - Kind: Secret text
     - Secret: Paste your SonarQube token
     - ID: `sonar-token`
     - Description: SonarQube authentication token
   - Save

3. **Add SonarQube Token as Jenkins Credential**
   - Go to **Manage Jenkins > Credentials**
   - Click **System > Global credentials**
   - Click **Add Credentials**
   - Kind: Secret text
   - Secret: Paste your SonarQube token
   - ID: `sonar-token`
   - Description: SonarQube token for pipeline
   - Save

## Create Jenkins Pipeline Job

1. **Create New Item**
   - Click **New Item** on Jenkins dashboard
   - Name: `sonar-poc-pipeline`
   - Type: **Pipeline**
   - Click **OK**

2. **Configure Pipeline**
   - Scroll to **Pipeline** section
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: Your Git repository URL
   - Credentials: Add if repository is private
   - Branch: `*/main` or `*/master`
   - Script Path: `jenkins/Jenkinsfile`
   - Click **Save**

3. **Run Pipeline**
   - Click **Build Now** on the pipeline job
   - Monitor the build progress

## Troubleshooting

### Jenkins can't access Docker
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### SonarQube connection issues
- Verify SonarQube is running: `docker ps`
- Check SonarQube logs: `docker-compose logs sonarqube`
- Verify token is correct in Jenkins credentials

### Pipeline fails on Trivy
- Ensure Trivy is installed: `trivy --version`
- Check if Docker image exists before scanning

## Pipeline Stages

The pipeline includes:
1. **Checkout**: Gets code from Git
2. **Build**: Creates Docker image
3. **Trivy Scan**: Security vulnerability scan
4. **SonarQube Analysis**: Code quality check
5. **Quality Gate**: Waits for SonarQube quality gate
6. **Deploy**: Runs the application container

