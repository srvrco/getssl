# Testing

Create virtualenv
    virtualenv -p python3 .venv

Use virtualenv
    source .venv\Scripts\activate

Install spotty
    pip install spotty

Run tests using Dockerfile on an Amazon AWS t2.micro spot instance
    spotty start
