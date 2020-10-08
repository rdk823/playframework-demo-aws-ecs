
/*---------------------------------
* Auto Scaling for ECS
*---------------------------------*/
resource "aws_iam_role" "app_ecs_autoscale_role" {
  name               = "${var.application_name}_${var.project}_ecs_autoscale_role"
  assume_role_policy = file("${path.module}/policies/ecs-autoscale-role.json")
}

resource "aws_iam_role_policy" "app_ecs_autoscale_role_policy" {
  name   = "${var.application_name}_${var.project}_ecs_autoscale_role_policy"
  policy = file("${path.module}/policies/ecs-autoscale-role-policy.json")
  role   = aws_iam_role.app_ecs_autoscale_role.id
}

resource "aws_appautoscaling_target" "app_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.app_ecs_autoscale_role.arn
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "app_up" {
  name                    = "${var.application_name}_${var.project}_scale_up"
  service_namespace       = "ecs"
  resource_id             = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension      = "ecs:service:DesiredCount"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }

  depends_on = [aws_appautoscaling_target.app_target]
}

resource "aws_appautoscaling_policy" "app_down" {
  name                    = "${var.application_name}_${var.project}_scale_down"
  service_namespace       = "ecs"
  resource_id             = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension      = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = [aws_appautoscaling_target.app_target]
}

/* metric used for auto scale */
resource "aws_cloudwatch_metric_alarm" "app_service_cpu_high" {
  alarm_name          = "${var.application_name}_${var.project}_cpu_utilization_high_auto_scaling"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.app_cluster.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [aws_appautoscaling_policy.app_up.arn]
  ok_actions    = [aws_appautoscaling_policy.app_down.arn]
}

