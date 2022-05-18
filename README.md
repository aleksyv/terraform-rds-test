## Test example to deploy RDS MySQL instance


Assuming the VPC and subnet exist, and deploying to private subnet for more security


The terraform code should create couple of resources:
* random password for MySQL instance access
* KMS key for storage encryption
* Security Group to protect RDS instance
* RDS instance
* Put the connection credentials to Secret Manager to not expose unsecurely


Room to improve:
*  keep state in cloud
*  separate VPC for RDS, private subnets and peering connection to other VPCs
*  secure backup implementation


## How to use:

AWS credentials configured, so terraform can use
Terraform installed
Prepare at least VPC id, subnet ids  and CIDR for Security Group to allow connection, for deployment


Example for  **terraform.tfvars**

	vpc_id = "vpc-XXXXXX"
	subnet_ids = ["subnet-XXXXXX", "subnet-XXXXXX"]
	cidr_block = ["0.0.0.0/0"]
	deletion_protection = false


Then just 

terraform init
terraform plan
terraform apply


## *Mine test output in output/aleksy-test.txt*