resource "aws_security_group" "rds" {
  name = format("%s-rds-sg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = {
    Group = var.name
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_identifier

  engine            = "postgres"
  engine_version    = "9.6.3"
  instance_class    = "db.t2.micro"
  allocated_storage = var.db_allocated_storage

  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = var.db_maintenance_window
  backup_window      = var.db_backup_window

  # disable backups to create DB faster
  backup_retention_period = var.db_backup_retention_period

  subnet_ids = module.vpc.database_subnets

  family = "postgres9.6"

  tags = {
    Group = var.name
  }
}

variable "db_identifier" {
  description = "The name of the RDS instance"
  default     = ""
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  default     = 5
}

variable "db_name" {
  description = "The DB name to create"
  default     = ""
}

variable "db_username" {
  description = "Username for the master DB user"
  default     = ""
}

variable "db_password" {
  description = "Password for the master DB user"
  default     = ""
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default     = 5432
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  default     = "Mon:00:00-Mon:03:00"
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default     = "03:00-06:00"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  default     = 0
}

