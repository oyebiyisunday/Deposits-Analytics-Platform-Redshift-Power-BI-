locals {
  pgb_image = "bitnami/pgbouncer:latest"
}

resource "aws_ecs_cluster" "pgb" {
  count = var.enable_pgbouncer ? 1 : 0
  name  = "${var.project}-pgb-cluster"
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement { actions=["sts:AssumeRole"] principals { type="Service" identifiers=["ecs-tasks.amazonaws.com"] } }
}

resource "aws_iam_role" "pgb_task" {
  count              = var.enable_pgbouncer ? 1 : 0
  name               = "${var.project}-pgb-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy" "pgb_task_policy" {
  count = var.enable_pgbouncer ? 1 : 0
  role  = aws_iam_role.pgb_task[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = "arn:aws:secretsmanager:${var.region}:*:secret:${var.project}/*" },
      { Effect = "Allow", Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource = "*" }
    ]
  })
}

resource "aws_cloudwatch_log_group" "pgb" {
  count             = var.enable_pgbouncer ? 1 : 0
  name              = "/aws/ecs/${var.project}-pgb"
  retention_in_days = 14
}

resource "aws_security_group" "pgb" {
  count       = var.enable_pgbouncer ? 1 : 0
  name        = "${var.project}-pgb-sg"
  description = "PgBouncer access"
  vpc_id      = aws_vpc.main.id

  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_security_group_rule" "pgb_ingress" {
  count             = var.enable_pgbouncer ? length(var.pgbouncer_allowed_cidrs) : 0
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [var.pgbouncer_allowed_cidrs[count.index]]
  security_group_id = aws_security_group.pgb[0].id
  description       = "Client access to PgBouncer"
}

resource "aws_lb" "pgb" {
  count              = var.enable_pgbouncer ? 1 : 0
  name               = "${var.project}-pgb-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for s in aws_subnet.private : s.id]
}

resource "aws_lb_target_group" "pgb" {
  count    = var.enable_pgbouncer ? 1 : 0
  name     = "${var.project}-pgb-tg"
  port     = 5432
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
  health_check { protocol = "TCP" }
}

resource "aws_lb_listener" "pgb" {
  count             = var.enable_pgbouncer ? 1 : 0
  load_balancer_arn = aws_lb.pgb[0].arn
  port              = 5432
  protocol          = "TCP"
  default_action { type = "forward" target_group_arn = aws_lb_target_group.pgb[0].arn }
}

resource "aws_ecs_task_definition" "pgb" {
  count                    = var.enable_pgbouncer ? 1 : 0
  family                   = "${var.project}-pgb"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.pgb_task[0].arn
  task_role_arn            = aws_iam_role.pgb_task[0].arn

  container_definitions = jsonencode([
    {
      name      = "pgbouncer",
      image     = local.pgb_image,
      essential = true,
      portMappings = [{ containerPort = 6432, hostPort = 6432, protocol = "tcp" }],
      environment = [
        { name = "POSTGRESQL_HOST",          value = aws_redshift_cluster.this.endpoint },
        { name = "POSTGRESQL_PORT_NUMBER",   value = "5439" },
        { name = "PGBOUNCER_PORT",           value = "6432" },
        { name = "PGBOUNCER_MAX_CLIENT_CONN",value = tostring(var.pgbouncer_max_client_conn) },
        { name = "PGBOUNCER_POOL_MODE",      value = "transaction" }
      ],
      secrets = [
        # Reference specific JSON keys from the Redshift secret
        { name = "PGBOUNCER_AUTH_USER",     valueFrom = "${aws_secretsmanager_secret.redshift.arn}:username::" },
        { name = "PGBOUNCER_AUTH_PASSWORD", valueFrom = "${aws_secretsmanager_secret.redshift.arn}:password::" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.pgb[0].name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "pgb" {
  count           = var.enable_pgbouncer ? 1 : 0
  name            = "${var.project}-pgb"
  cluster         = aws_ecs_cluster.pgb[0].id
  task_definition = aws_ecs_task_definition.pgb[0].arn
  desired_count   = var.pgbouncer_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.pgb[0].id]
    subnets          = [for s in aws_subnet.private : s.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.pgb[0].arn
    container_name   = "pgbouncer"
    container_port   = 6432
  }
}

output "pgbouncer_endpoint" {
  value       = try(aws_lb.pgb[0].dns_name, null)
  description = "Internal NLB DNS name for PgBouncer on port 5432 -> container 6432"
}

