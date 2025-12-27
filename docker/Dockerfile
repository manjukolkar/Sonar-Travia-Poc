FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install SonarQube Scanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner-cli-5.0.1.3006-linux.zip -d /opt && \
    mv /opt/sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner && \
    rm sonar-scanner-cli-5.0.1.3006-linux.zip

# Install Trivy
RUN wget -qO- "https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.tar.gz" | tar -xz -C /usr/local/bin/ trivy && \
    chmod +x /usr/local/bin/trivy

# Copy application files
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/app.py .
COPY app/templates/ ./templates/
COPY app/static/ ./static/

# Add SonarQube Scanner to PATH
ENV PATH="/opt/sonar-scanner/bin:${PATH}"

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]

