import os
from flask import Flask, jsonify
from .qiskit_utils import *

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')

@app.route('/')
def home():
    return jsonify({"message": "Hello from the CI/CD CLI tool API with secret key: {}".format(app.config['SECRET_KEY'])})


@app.route('/api/random/<int:bits>', methods=['GET'])
def quantum_random(bits):
    """Generate a quantum random number of specified bit length."""
    random_number = generate_quantum_random_number(bits)
    return jsonify({'quantum_random_number': random_number})


if __name__ == '__main__':
    app.run(debug=True)
