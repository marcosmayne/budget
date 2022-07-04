terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket = "920842611405-terraform-state"
    # key should be defined in terraform init
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "hello_django" {
  name = var.application_name
  tags = {
    application = var.application_name
    environment = "production"
  }
}

resource "aws_db_instance" "hello_django" {
  identifier             = var.application_name
  engine                 = "postgres"
  engine_version         = "13.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  db_name                = var.database_name
  username               = var.database_username
  password               = var.database_password
  port                   = 5432
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.default_security_group]
  tags = {
    application = var.application_name
    environment = "production"
  }
}

resource "aws_iam_role" "app_runner_ecr" {
  name = "${var.application_name}-app-runner-ecr"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "build.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"]
}

resource "aws_iam_role" "app_runner_rds" {
  name = "${var.application_name}-app-runner-rds"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "tasks.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"]
}

resource "aws_apprunner_vpc_connector" "hello_django" {
  vpc_connector_name = var.application_name
  subnets            = var.subnets
  security_groups    = [var.default_security_group]
  tags = {
    application = var.application_name
    environment = "production"
  }
}

resource "aws_apprunner_service" "hello_django" {
  service_name = var.application_name
  source_configuration {
    auto_deployments_enabled = false
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_ecr.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.hello_django.repository_url}:${var.application_version}"
      image_repository_type = "ECR"
      image_configuration {
        port          = 8000
        start_command = "python -m gunicorn -w 2 -b 0.0.0.0:8000 core.wsgi"
        runtime_environment_variables = {
          APPLICATION_DEBUG_ENABLED = var.application_debug_enabled
          APPLICATION_SECRET_KEY    = var.application_secret_key
          DATABASE_HOST             = aws_db_instance.hello_django.address
          DATABASE_PORT             = aws_db_instance.hello_django.port
          DATABASE_NAME             = aws_db_instance.hello_django.db_name
          DATABASE_USERNAME         = aws_db_instance.hello_django.username
          DATABASE_PASSWORD         = aws_db_instance.hello_django.password
        }
      }
    }
  }
  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.hello_django.arn
    }
  }
  instance_configuration {
    instance_role_arn = aws_iam_role.app_runner_rds.arn
  }
  tags = {
    application = var.application_name
    environment = "production"
  }
}
