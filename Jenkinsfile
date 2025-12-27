pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube'  // configured name in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/manjukolkar/Sonar-Travia-Poc.git'
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh 'sonar-scanner -Dsonar.projectKey=devsecops-landing-page -Dsonar.sources=app -Dsonar.host.url=http://54.197.126.6:9000'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t devsecops-landing-page:latest .'
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                // Fail if HIGH or CRITICAL vulnerabilities found
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL devsecops-landing-page:latest || true'
            }
        }

        stage('Deploy (Optional)') {
            steps {
                echo "Deployment step placeholder"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed. Check SonarQube/Trivy logs."
        }
    }
}

