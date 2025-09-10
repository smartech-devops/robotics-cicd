#!/usr/bin/env python3
"""
Simple Hello World application for CI/CD demonstration
"""

import os
import datetime
from flask import Flask, jsonify

app = Flask(__name__)

# Application version (will be updated by CI/CD pipeline)
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.datetime.now().isoformat())

@app.route('/')
def hello_world():
    """Main endpoint returning hello message with version info"""
    return jsonify({
        'message': 'Hello from CI/CD!',
        'application': 'robotics-cicd-demo',
        'version': APP_VERSION,
        'build_date': BUILD_DATE,
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/health')
def health_check():
    """Health check endpoint for container orchestration"""
    return jsonify({
        'status': 'healthy',
        'version': APP_VERSION,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/version')
def version():
    """Version endpoint for monitoring"""
    return jsonify({
        'version': APP_VERSION,
        'build_date': BUILD_DATE,
        'application': 'robotics-cicd-demo'
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'
    
    print(f"Starting robotics-cicd-demo v{APP_VERSION}")
    print(f"Server running on port {port}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)