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
echo "import click

@click.command()
def main():
    click.echo('Hello, this is my CI/CD CLI tool!')

if __name__ == '__main__':
    main()" > myci/cli.py

# Create Dockerfile
echo "FROM python:3.8-slim
WORKDIR /usr/src/app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ['python', 'myci/cli.py']" > Dockerfile

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
