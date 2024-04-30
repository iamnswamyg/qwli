import os
from flask import Flask, jsonify
from .qiskit_utils import create_quantum_circuit, run_simulation

app = Flask(__name__)
app.config['HELLO_WORLD'] = os.getenv('HELLO_WORLD')

@app.route('/')
def home():
    return jsonify({"message": "Hello from the CI/CD CLI tool API with secret key: {}".format(app.config['SECRET_KEY'])})


@app.route('/quantum/<int:bits>')
def quantum_random(bits):
    circuit = create_quantum_circuit(bits)
    result = run_simulation(circuit)
    return jsonify({"result": result})


if __name__ == '__main__':
    app.run(debug=True)
