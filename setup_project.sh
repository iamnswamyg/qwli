#!/bin/bash

# Check if sufficient arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <github-username> <repo-name>"
    exit 1
fi

# Assign command line arguments to variables
USERNAME=$1
REPO_NAME=$2

# Install GitHub CLI if not already installed
if ! command -v gh &> /dev/null
then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
fi

# Authenticate GitHub CLI
gh auth login

# Create and clone GitHub repository
REPO_DESC="A CLI tool for automating CI/CD pipeline creation."
gh repo create $REPO_NAME --public --description "$REPO_DESC"
gh repo clone $USERNAME/$REPO_NAME

# Navigate to the project directory
cd $REPO_NAME

# Setup Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "click" > requirements.txt
pip install -r requirements.txt

# Create necessary project files
echo "Initializing project structure..."
mkdir -p $REPO_NAME
touch $REPO_NAME/__init__.py
touch $REPO_NAME/cli.py

# Write basic CLI tool example in cli.py
echo echo "from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({'message': 'Welcome to the CI/CD CLI tool API!'})

if __name__ == '__main__':
    app.run(debug=True)"> $REPO_NAME/cli.py

# Assuming previous setup steps are preserved, add Qiskit setup below:
echo "from qiskit import QuantumCircuit, Aer, execute

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
    return result.get_counts(circuit)" > myci/qiskit_utils.py

# Create Dockerfile
echo "# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the local directory contents into the container at /usr/src/app
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run api.py when the container launches
CMD ["python", "$REPO_NAME/api.py"]


# docker run --env-file .env myapp']" > Dockerfile

# Create systemd service file for system service
echo "[Unit]
Description=My CI/CD CLI Tool API
After=network.target

[Service]
User=www-data
WorkingDirectory=/usr/src/app
ExecStart=/usr/bin/python3 /usr/src/app/$REPO_NAME/api.py
Restart=always

[Install]
WantedBy=multi-user.target" > $REPO_NAME.service

# Create .env files
touch .env.local .env.test .env

# Update .gitignore to exclude env files
echo "
# Environment secrets
.env*
!.env.example" >> .gitignore

# Create .dockerignore
echo "venv/
__pycache__
*.pyc
*.pyo
*.pyd
.git
.gitignore
*.log" > .dockerignore

# Create .gitignore
echo "__pycache__/
*.py[cod]
*$py.class
venv/
.env/" > .gitignore

# Git add and commit
git add .
git commit -m "Initial project setup"
git push -u origin main

echo "Project setup is complete."

# Create GitHub Actions directory and workflow file
mkdir -p .github/workflows
echo "name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8

    - name: Build and Publish Docker Image
      run: |
        docker build -t \${{ secrets.DOCKER_USERNAME }}/myci-cli:\${{ github.sha }} .
        echo \"\${{ secrets.DOCKER_PASSWORD }}\" | docker login -u \"\${{ secrets.DOCKER_USERNAME }}\" --password-stdin
        docker push \${{ secrets.DOCKER_USERNAME }}/myci-cli:\${{ github.sha }}

    - name: Push to PyPI
      run: |
        docker run --rm \${{ secrets.DOCKER_USERNAME }}/myci-cli:\${{ github.sha }} python setup.py sdist bdist_wheel
        twine upload dist/* --username \${{ secrets.PYPI_USERNAME }} --password \${{ secrets.PYPI_PASSWORD }}
" > .github/workflows/ci-cd.yml

# Git add and commit the new GitHub Actions setup
git add .github/workflows/ci-cd.yml
git commit -m "Add GitHub Actions CI/CD workflow"
git push

# Create the GitLab CI/CD configuration
echo "stages:
  - build
  - test
  - deploy

variables:
  IMAGE_TAG: \$CI_REGISTRY_IMAGE:\$CI_COMMIT_SHA

build:
  stage: build
  image: docker:19.03
  services:
    - docker:19.03-dind
  script:
    - docker login -u \$CI_REGISTRY_USER -p \$CI_REGISTRY_PASSWORD \$CI_REGISTRY
    - docker build -t \$IMAGE_TAG .
    - docker push \$IMAGE_TAG

test:
  stage: test
  image: \$IMAGE_TAG
  script:
    - echo \"Run tests here\"
    - python -m unittest discover

deploy:
  stage: deploy
  image: docker:19.03
  script:
    - docker pull \$IMAGE_TAG
    - echo \"Deploy commands go here\"
    - echo \"This could be a script to update a server or a service\"
" > .gitlab-ci.yml

# Create .env file for storing secrets and configurations
echo "SECRET_KEY=your_secret_key_here" > .env
echo "MONGO_INITDB_ROOT_USERNAME=mongoadmin" >> .env
echo "MONGO_INITDB_ROOT_PASSWORD=mongopassword" >> .env

# Update Docker Compose to use the .env file
echo "version: '3.8'
services:
  webapp:
    build: .
    container_name: myci-cli-web
    ports:
      - \"5000:5000\"
    environment:
      - SECRET_KEY=\${SECRET_KEY}
    depends_on:
      - mongo
    networks:
      - app-network

  mongo:
    image: mongo
    container_name: myci-cli-mongo
    ports:
      - \"27017:27017\"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=\${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=\${MONGO_INITDB_ROOT_PASSWORD}
    volumes:
      - mongo-data:/data/db
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mongo-data:
    driver: local" > docker-compose.yml

# Add .env files to .gitignore to avoid uploading sensitive information
echo "
# Environment secrets
.env*" >> .gitignore

# Commit changes to Git
git add .env .gitignore docker-compose.yml
git commit -m "Setup environment variables and update Docker compose"
git push



