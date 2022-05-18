#Random suffix for Secret name for faster tests
resource "random_id" "suffix" {
  byte_length = 4
}


resource "aws_db_subnet_group" "mysql" {
  name              = "${var.database_name}-sg"
  subnet_ids        = var.subnet_ids
  tags              = var.rds_tags  
}

#AWS security group to secure connection
resource "aws_security_group" "allow_mysql" {
  name               = "allow_mysql"
  description       = "Allow connection to MySQL"
  vpc_id            = var.vpc_id
  ingress {
    description      = "Mysql from VPC"
    from_port        = var.rds_port
    to_port          = var.rds_port
    protocol         = "tcp"
    cidr_blocks      = var.cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mysql"
  }
}

data "aws_security_group" "allow_mysql_id" {
  name                      = aws_security_group.allow_mysql.name
  depends_on                = [aws_security_group.allow_mysql]
}

#Generate password for MySQL user
resource "random_password" "rds_password"{
  length                    = 16
  special                   = true
  override_special          = "_!%^"
}

#Create KMS key for encryption
resource "aws_kms_key" "rds" {
  description              = "RDS MySQL KMS key"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 10
  tags                     = var.rds_tags
}


#Create RDS instance
resource "aws_db_instance" "mysql" {
  
  db_name                 = var.database_name
  username                = var.username
  password                = random_password.rds_password.result

  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.storage_encrypted == true ? aws_kms_key.rds.arn : null

  deletion_protection     = var.deletion_protection

  publicly_accessible     = var.publicly_accessible

  #Lets try custom port for security
  port                    = var.rds_port

  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  vpc_security_group_ids  = [data.aws_security_group.allow_mysql_id.id]

  multi_az                = var.enable_replication
  
  skip_final_snapshot     = true

  tags                    = var.rds_tags

  depends_on = [
    aws_kms_key.rds,
    random_password.rds_password
  ]
  
}

#Create AWS Secret and put connection details there
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds_credentials-${random_id.suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  depends_on    = [aws_db_instance.mysql]
  secret_string = <<EOF
{
  "username": "${aws_db_instance.mysql.username}",
  "password": "${random_password.rds_password.result}",
  "engine": "mysql",
  "host": "${aws_db_instance.mysql.endpoint}",
  "port": ${aws_db_instance.mysql.port}
}
EOF
}
