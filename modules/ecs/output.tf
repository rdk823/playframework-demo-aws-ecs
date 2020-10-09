output "registry_id" {
  value = aws_ecr_repository.app.registry_id
}

output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "alb_dns_name" {
  value = aws_route53_record.www.fqdn
}

output "alb_zone_id" {
  value = aws_alb.app.zone_id
}

output "security_group_id" {
  value = aws_security_group.app_ecs_service.id
}

output "app_inbound_security_group_id" {
  value = aws_security_group.app_alb_sg.id
}

output "application_log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "application_ecs_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "application_ecs_service_name" {
  value = aws_ecs_service.app.name
}