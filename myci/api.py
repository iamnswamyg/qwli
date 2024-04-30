import os
from flask import Flask, jsonify

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')

@app.route('/')
def home():
    return jsonify({"message": "Hello from the CI/CD CLI tool API with secret key: {}".format(app.config['SECRET_KEY'])})


if __name__ == '__main__':
    app.run(debug=True)
