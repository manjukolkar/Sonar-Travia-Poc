# DevSecOps Landing Page (FastAPI)

A simple Python FastAPI application used to demonstrate **SonarQube** (code quality) and **Trivy** (security) scans within a Jenkins CI/CD pipeline.

## 🚀 Features
- Lightweight FastAPI web app
- Dockerized
- Integrated with SonarQube and Trivy
- Jenkins pipeline ready

## 🛠️ Run locally
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Open [http://localhost:8000](http://localhost:8000)

## 🐳 Build Docker Image
```bash
docker build -t devsecops-landing-page .
docker run -d -p 8000:8000 devsecops-landing-page
```

