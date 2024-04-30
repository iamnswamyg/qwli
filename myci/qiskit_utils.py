from qiskit import QuantumCircuit, Aer, execute

def create_quantum_circuit(bits):
    circuit = QuantumCircuit(bits, bits)
    for i in range(bits):
        circuit.h(i)
    circuit.measure(range(bits), range(bits))
    return circuit

def run_simulation(circuit, shots=1024):
    simulator = Aer.get_backend('qasm_simulator')
    job = execute(circuit, simulator, shots=shots)
    result = job.result()
    return result.get_counts(circuit)

def generate_quantum_random_number(bits=8):
    circuit = QuantumCircuit(bits, bits)
    circuit.h(range(bits))  # Apply Hadamard gate to all qubits
    circuit.measure(range(bits), range(bits))
    simulator = Aer.get_backend('qasm_simulator')
    result = execute(circuit, simulator, shots=1).result()
    counts = result.get_counts()
    return list(counts.keys())[0]  # Return the measured bits as a string