output "rds_address" {
  value = aws_db_instance.rds.address
}

output "db_access_sg_id" {
  value = aws_security_group.db_access_sg.id
}

output "rds_database_identifier" {
  value = aws_db_instance.rds.identifier
}

output "db_username" {
  value = random_string.username.result
}

output "db_password" {
  value = random_password.password.result
}