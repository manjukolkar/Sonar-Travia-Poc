#!/usr/bin/env python3
"""
Simple Landing Page Application for CI/CD POC
This application provides a web interface to check code quality via SonarQube and Trivy
"""

from flask import Flask, render_template, request, jsonify
import subprocess
import os
import json
from datetime import datetime

app = Flask(__name__)

# Configuration
SONARQUBE_URL = os.getenv('SONARQUBE_URL', 'http://localhost:9000')
SONARQUBE_TOKEN = os.getenv('SONARQUBE_TOKEN', '')
PROJECT_KEY = os.getenv('SONAR_PROJECT_KEY', 'sonar-poc')

@app.route('/')
def index():
    """Main landing page"""
    return render_template('index.html')

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'sonarqube': check_sonarqube_status(),
            'trivy': check_trivy_status()
        }
    })

@app.route('/api/sonar/scan', methods=['POST'])
def sonar_scan():
    """Trigger SonarQube scan"""
    try:
        # Run sonar-scanner
        result = subprocess.run(
            ['sonar-scanner'],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        return jsonify({
            'success': result.returncode == 0,
            'output': result.stdout,
            'error': result.stderr,
            'timestamp': datetime.now().isoformat()
        })
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Scan timed out after 5 minutes',
            'timestamp': datetime.now().isoformat()
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/trivy/scan', methods=['POST'])
def trivy_scan():
    """Trigger Trivy security scan"""
    try:
        image_name = request.json.get('image', 'app:latest')
        scan_type = request.json.get('type', 'image')  # image, fs, repo
        
        if scan_type == 'image':
            result = subprocess.run(
                ['trivy', 'image', '--format', 'json', image_name],
                capture_output=True,
                text=True,
                timeout=300
            )
        elif scan_type == 'fs':
            path = request.json.get('path', '.')
            result = subprocess.run(
                ['trivy', 'fs', '--format', 'json', path],
                capture_output=True,
                text=True,
                timeout=300
            )
        else:
            return jsonify({
                'success': False,
                'error': 'Invalid scan type. Use "image" or "fs"',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        try:
            scan_results = json.loads(result.stdout) if result.stdout else {}
        except json.JSONDecodeError:
            scan_results = {'raw_output': result.stdout}
        
        return jsonify({
            'success': result.returncode == 0,
            'results': scan_results,
            'output': result.stdout,
            'error': result.stderr,
            'timestamp': datetime.now().isoformat()
        })
    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Scan timed out after 5 minutes',
            'timestamp': datetime.now().isoformat()
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/sonar/project', methods=['GET'])
def get_sonar_project():
    """Get SonarQube project information"""
    try:
        import requests
        url = f"{SONARQUBE_URL}/api/projects/search"
        params = {'q': PROJECT_KEY}
        
        if SONARQUBE_TOKEN:
            headers = {'Authorization': f'Bearer {SONARQUBE_TOKEN}'}
        else:
            headers = {}
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({
                'error': f'SonarQube API returned status {response.status_code}',
                'message': response.text
            }), response.status_code
    except Exception as e:
        return jsonify({
            'error': str(e),
            'message': 'Unable to connect to SonarQube'
        }), 500

def check_sonarqube_status():
    """Check if SonarQube is accessible"""
    try:
        import requests
        response = requests.get(f"{SONARQUBE_URL}/api/system/status", timeout=5)
        return response.status_code == 200
    except:
        return False

def check_trivy_status():
    """Check if Trivy is installed and working"""
    try:
        result = subprocess.run(
            ['trivy', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0
    except:
        return False

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

