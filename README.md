# HELLO-DJANGO

A simple web application template.

# Stack

1. Python 3.10 as programming language
2. Django 4.0 as web framework
3. Bootstrap 5.0 as interface components
4. PostgreSQL 13.6 as database
5. Docker 20.10 as containers manager
6. Terraform 1.2 as IaC
7. AWS as cloud provider
8. GitHub as repo and workflows manager

# Application settings

Application settings are defined as environment variables:

1. `APPLICATION_DEBUG_ENABLED`: enables / disables application debug, valid
values are `yes` or `no`
2. `APPLICATION_SECRET_KEY`: sets the application's secret that will be used to
hash sensitive data like passwords (secret)
3. `DATABASE_HOST`: sets the database host
4. `DATABASE_PORT`: sets the database port
5. `DATABASE_NAME`: sets the database name
6. `DATABASE_USERNAME`: sets the database username
7. `DATABASE_PASSWORD`: sets the database password (secret)

# Requirements

1. AWS account 
2. AWS network and security setup, including VPC, subnets, route table, IGW,
ACL, SGs
3. AWS IAM users for developers (read-only) and GitHub Actions
4. AWS S3 bucket for Terraform state
5. GitHub user AWS credentials configured as secrets in GitHub repository
(`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`)
6. Application settings secrets configured as secrets in GitHub repository
(`APPLICATION_SECRET_KEY` and `DATABASE_PASSWORD`)

# Development environment

This project uses Docker + Code Development Containers feature to provide a
consistent and easy to use development environment.

## Requirements

1. Windows 10 + WSL2 / macOS Monterey 12
2. Docker 20
3. Code (latest version)
4. Remote Container extension (latest version)

## Initial setup

Clone this repository:

    cd ~/code/github/brunitto
    git clone git@github.com:brunitto/hello-django.git

Open in VS Code:

    code hello-django

This will detect the development container configuration within `.devcontainer`
directory and start the development environment, using the
`docker-compose.yaml` and `Dockerfile` files.

Run an application check:

    python manage.py check

This will check if there are any configuration problem.

The output should be something like:

    System check identified no issues (0 silenced).

Run the application's migrations:

    python manage.py migrate

This will create the necessary database tables.

## Tests

Run the tests

    python manage.py test

Run the tests under coverage:

    python -m coverage run --include 'main/*' manage.py test

Check the coverage report:

    python -m coverage report --show-missing

This will ensure that are no code without tests.

## Development server

Run the development server:

    python manage.py runserver 0.0.0.0:8000

This will start a simple development server within the container, available at:
http://localhost:8000.

You can also use Gunicorn, also available at http://localhost:8000:

    python -m gunicorn -w 2 -b 0.0.0.0:8000 core.wsgi

This is how the application will run in production environment.

## Development workflow

To use git within the development container, it's necessary to start a SSH
agent and add your keys, so the extension will forward the agent to the
development container:

    ssh-agent
    ssh-add

More information available at:
https://code.visualstudio.com/docs/remote/containers#_using-ssh-keys

Start from branch `main`:

    git checkout main
    git pull origin main

Create branch `development` from `main`:

    git checkout -b development

Note: if the branch `development` exists, just checkout:

    git checkout development

Code, add files and commit when you have tested and working code:

    git add ...
    git commit ...

Push the `development` branch to trigger the CI workflow!

# Production environment

## Requirements

1. AWS VPC
2. AWS IAM
3. AWS S3
4. AWS RDS
5. AWS App Runner
6. AWS CloudWatch

## Infrastructure provisioning

This project uses Terraform to provision infrastructure in AWS. This
provisioning should be handled by the CI/CD workflows, but here's how it works,
for documentation purpose.

Initialize Terraform:

    terraform init -backend-config="key=hello-django/key"

This will create the Terraform configuration and state.

Plan:

    terraform plan -out tfplan

This will check the Terraform modules and AWS resources, and create a plan to
provision the required resources.

Apply:

    terraform apply tfplan

This will provision the required resources in AWS.

## Release workflow

From a tested and working ref (commit or branch), create and push a new tag
using semantic versioning:

    git checkout development
    git tag 1.0.0
    git push origin 1.0.0

Create a new release in GitHub, selecting the tag, to trigger the CD workflow!

**Note: the tag name will be used as container image tag.**

# Continuous integration (CI)

This project's continuous integration uses GitHub Actions and is configured in
the `.github/workflows/ci.yaml` file.

# Continuous deployment (CD)

This project's continuous deployment uses GitHub Actions and is configured in
the `.github/workflows/cd.yaml` file.
