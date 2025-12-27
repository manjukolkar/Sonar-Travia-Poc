# Quick Start Guide

## Prerequisites Checklist

- [ ] AWS EC2 instance launched (Amazon Linux 2023 or 2)
- [ ] Security group configured with required ports
- [ ] SSH access to EC2 instance
- [ ] Git repository created (GitHub, GitLab, etc.)

## Step-by-Step Setup

### 1. Clone Repository to EC2

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ec2-user@<your-ec2-ip>

# Clone your repository
git clone <your-repo-url>
cd sonar-poc
```

### 2. Run Installation Script

```bash
# Make script executable
chmod +x scripts/install-all-tools.sh

# Run installation (this will take 10-15 minutes)
sudo ./scripts/install-all-tools.sh
```

**Note**: After installation, you may need to log out and log back in for Docker group permissions.

### 3. Start SonarQube

```bash
# Navigate to docker directory
cd docker

# Start SonarQube and PostgreSQL
docker-compose up -d

# Check if containers are running
docker ps

# View logs if needed
docker-compose logs -f sonarqube
```

Wait 2-3 minutes for SonarQube to fully start.

### 4. Access SonarQube

1. Open browser: `http://<your-ec2-ip>:9000`
2. Login with default credentials:
   - Username: `admin`
   - Password: `admin`
3. Change password when prompted
4. Create a new project:
   - Project key: `sonar-poc`
   - Display name: `Sonar POC`
5. Generate a token:
   - Go to **My Account > Security**
   - Generate token: `jenkins-token`
   - **Save this token** - you'll need it for Jenkins

### 5. Access Jenkins

1. Get initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

2. Open browser: `http://<your-ec2-ip>:8080`
3. Enter the admin password
4. Install suggested plugins
5. Create admin user
6. Follow **JENKINS_SETUP.md** for complete Jenkins configuration

### 6. Run the Application Locally (Optional)

```bash
# Navigate to app directory
cd app

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run application
python app.py
```

Access at: `http://<your-ec2-ip>:5000`

### 7. Test the Pipeline

1. Configure Jenkins pipeline (see JENKINS_SETUP.md)
2. Push code to your Git repository
3. Trigger Jenkins pipeline
4. Monitor build progress

## Verification Checklist

- [ ] Git is installed and working
- [ ] Docker is running: `sudo systemctl status docker`
- [ ] Jenkins is running: `sudo systemctl status jenkins`
- [ ] SonarQube is accessible: `http://<your-ec2-ip>:9000`
- [ ] Trivy is installed: `trivy --version`
- [ ] Application runs locally: `python app.py`

## Common Issues

### Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :8080  # For Jenkins
sudo lsof -i :9000  # For SonarQube

# Stop the service if needed
sudo systemctl stop <service-name>
```

### Docker Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker ec2-user
# Log out and log back in
```

### SonarQube Not Starting
```bash
# Check Docker logs
docker-compose logs sonarqube

# Check system resources
free -h
df -h

# SonarQube needs at least 2GB RAM
```

### Jenkins Can't Access Docker
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## Next Steps

1. Configure Jenkins pipeline (see JENKINS_SETUP.md)
2. Set up Git webhooks for automatic builds
3. Customize SonarQube quality gates
4. Add more security scanning rules in Trivy
5. Set up monitoring and alerts

## Support

For detailed information, refer to:
- **README.md**: Complete project documentation
- **JENKINS_SETUP.md**: Jenkins configuration guide

