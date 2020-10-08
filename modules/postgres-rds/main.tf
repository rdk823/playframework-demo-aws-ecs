/*---------------------------------
* RDS
*---------------------------------*/
/* subnet used by rds */
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project}-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = flatten(var.subnet_ids)
  tags = {
    project = var.project
  }
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.project}-db-access-sg"
  description = "Allow access to RDS"

  tags = {
    Name        = "${var.project}-db-access-sg"
    project = var.project
  }
}

resource "aws_security_group" "rds_sg" {
  name = "${var.project}-rds-sg"
  description = "${var.project} Security Group"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.project}-rds-sg"
    project =  var.project
  }

  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow traffic for TCP 5432
  ingress {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      security_groups = [aws_security_group.db_access_sg.id]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "username" {
  length = 8
  special = false
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.project}-database"
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = "11"
  instance_class         = var.instance_class
  multi_az               = var.multi_az
  name                   = var.database_name
  username               = random_string.username.result
  password               = random_password.password.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  
  tags = {
    project = var.project
  }
}