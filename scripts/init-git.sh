#!/bin/bash

# Git Repository Initialization Script

echo "========================================="
echo "Initializing Git Repository"
echo "========================================="

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo "Initializing new Git repository..."
    git init
    echo "Git repository initialized."
else
    echo "Git repository already initialized."
fi

# Add all files
echo "Adding files to Git..."
git add .

# Create initial commit
echo "Creating initial commit..."
git commit -m "Initial commit: CI/CD POC with Git, Jenkins, Docker, SonarQube, and Trivy"

echo ""
echo "========================================="
echo "Git Repository Ready!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Add remote repository:"
echo "   git remote add origin <your-repo-url>"
echo ""
echo "2. Push to remote:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

