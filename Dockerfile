# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the local directory contents into the container at /usr/src/app
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Twine for uploading packages to PyPI
RUN pip install twine

# Run tests or other necessary commands
CMD ["python", "setup.py", "sdist bdist_wheel && twine upload dist/*"]
