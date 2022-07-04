output "application_endpoint" {
  value = aws_apprunner_service.hello_django.service_url
}

output "database_endpoint" {
  value = aws_db_instance.hello_django.address
}
