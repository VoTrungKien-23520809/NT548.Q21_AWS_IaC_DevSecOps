from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"service": "backend", "status": "running"})

@app.route('/api/hello')
def hello():
    return jsonify({"message": "Hello from NT548 Backend!", "version": "1.0"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
