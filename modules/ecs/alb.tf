/*---------------------------------
* AWS certificate for the domain
*---------------------------------*/

resource "aws_acm_certificate" "cert" {
  domain_name       = var.acm_cert_domain
  subject_alternative_names = ["www.${var.acm_cert_domain}"]
  validation_method = "DNS"

  tags = {
    project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_route53_zone" "selected" {
  name         = var.acm_cert_domain
  private_zone = false
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
/*---------------------------------
* App Load Balancer
*---------------------------------*/

resource "aws_alb_target_group" "app_alb_target_group" {
  name     = "${var.application_name}-${var.project}-atg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {   
    healthy_threshold   = 3    
    unhealthy_threshold = 3    
    timeout             = 5    
    interval            = 30    
    path                = "/health"    
    protocol            = "HTTP"
    matcher             = "200-299"  
  }
}

/* security group for ALB */
resource "aws_security_group" "app_alb_sg" {
  name        = "${var.application_name}-${var.project}-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application_name}-${var.project}-inbound-sg"
  }
}

/* DNS record for ALB */
resource "aws_alb" "app" {
  name            = "${var.application_name}-${var.project}-alb"
  subnets         = flatten(var.public_subnet_ids)
  security_groups = flatten([var.security_groups_ids, aws_security_group.app_alb_sg.id, aws_security_group.app_ecs_service.id])

  tags = {
    Name        = "${var.application_name}-${var.project}-alb"
    project = var.project
  }
}

resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.app.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.app_alb_target_group]

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "app_ssl" {
  load_balancer_arn = aws_alb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  depends_on        = [aws_alb_target_group.app_alb_target_group]
  certificate_arn   = aws_acm_certificate_validation.validation.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.app_alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_alb.app.dns_name
    zone_id                = aws_alb.app.zone_id
    evaluate_target_health = true
  }
}
