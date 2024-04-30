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
