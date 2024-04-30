from setuptools import setup, find_packages

setup(
    name='qcli',
    version='0.1.0',
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'myci=myci.cli:main'
        ],
    },
    install_requires=[
        'Click',  # Assuming you are using Click for your CLI
    ],
    python_requires='>=3.6',
)
