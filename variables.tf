variable "vpc_id" {
  type        = string
  description = "VPC id to deploy RDS"
}

variable "subnet_ids" {
  type        = set(string)
}

variable "cidr_block" {
  type        = list(string)
  default     = []
} 


variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
  default     = "gartnersql"
}

variable "username" {
  type        = string
  default     = "admin"
}

variable "deletion_protection" {
  type        = bool
  description = "Set to true to enable deletion protection on the RDS instance"
  default     = true
}


variable "multi_az" {
  type        = bool
  description = "Set to true if multi AZ deployment must be supported"
  default     = false
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  default     = "gp2"
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted"
  default     = true
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in GBs"
  default     = 10
}

variable "engine_version" {
  type        = string
  description = "The engine version"
  default     = "5.7"
}

variable "instance_class" {
  type        = string
  description = "Class of RDS instance"
  default     = "db.t3.micro"
}


variable "rds_tags" {
  type  =  map(string)
  default = {
    environment = "test"
    owner       = "aleksy"
  }
}

variable "enable_replication" {
  type    = string
  default = false
}

variable "publicly_accessible" {
  type      = bool
  default   = false
}


variable "rds_port" {
  type    = string
  default = "3307"
  description = "Custom port for RDS instance"
}