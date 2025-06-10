# ==============================================
# FILE: src/app.py
# ==============================================
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    environment = os.getenv('ENVIRONMENT', 'unknown')
    return jsonify({
        'message': f'Hello from {environment} environment!',
        'environment': environment,
        'status': 'running'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'environment': os.getenv('ENVIRONMENT', 'unknown')})

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT', 8080))
    app.run(host='0.0.0.0', port=port)






