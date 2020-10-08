
/*---------------------------------
* Cloudwatch Log Group
*---------------------------------*/
resource "aws_cloudwatch_log_group" "app" {
  name = "${var.application_name}-${var.project}"
  retention_in_days = var.log_retention_in_days
  tags = {
    project = var.project
    Application = var.application_name
  }
}

/*---------------------------------
* IAM service roles and policies
*---------------------------------*/
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ecs_role" {
  name               = "${var.application_name}_${var.project}_ecs_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_role.json
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "app_ecs_service_role_policy" {
  name   = "${var.application_name}_${var.project}_ecs_service_role_policy"
  policy = file("${path.module}/policies/ecs-service-role.json")
  role   = aws_iam_role.app_ecs_role.id
}

/* role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "app_ecs_execution_role" {
  name               = "${var.application_name}_${var.project}_ecs_task_execution_role"
  assume_role_policy = file("${path.module}/policies/ecs-task-execution-role.json")
}

resource "aws_iam_role_policy" "app_ecs_execution_role_policy" {
  name   = "${var.application_name}_${var.project}_ecs_execution_role_policy"
  policy = file("${path.module}/policies/ecs-execution-role-policy.json")
  role   = aws_iam_role.app_ecs_execution_role.id
}


/*---------------------------------
* ECS task definitions
*---------------------------------*/

/* the task definition for the app service */
data "template_file" "app_task" {
  template = file("${path.module}/tasks/app_task_definition.json")

  vars = {
    image                = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
    region               = var.region
    app_name             = var.application_name
    log_group            = aws_cloudwatch_log_group.app.name
    container_port       = var.container_port
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.application_name}_${var.project}"
  container_definitions    = data.template_file.app_task.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.app_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.app_ecs_execution_role.arn
}


/*---------------------------------
* ECS service
*---------------------------------*/

/* Security Group for ECS */
resource "aws_security_group" "app_ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.project}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 9000
      to_port = 9000
      protocol = "tcp"
      security_groups = [aws_security_group.app_alb_sg.id]
  }

  tags = {
    Name        = "${var.project}-ecs-service-sg"
    project = var.project
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.application_name}-${var.project}"
  task_definition = aws_ecs_task_definition.app.family
  desired_count   = var.min_capacity
  deployment_maximum_percent = "200"
  deployment_minimum_healthy_percent = "50"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.app_cluster.id
  depends_on      = [aws_iam_role_policy.app_ecs_service_role_policy, aws_alb_target_group.app_alb_target_group]

  network_configuration {
    security_groups = flatten([var.security_groups_ids, aws_security_group.app_ecs_service.id])
    subnets         = flatten(var.subnets_ids)
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app_alb_target_group.arn
    container_name   = var.application_name
    container_port   = var.container_port
  }
}

