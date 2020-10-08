output "ecr-registry-id" {
  value = module.ecs.registry_id
}

output "ecr-repository-url" {
  value = module.ecs.repository_url
}

output "alb-dns-name" {
  value = module.ecs.alb_dns_name
}
