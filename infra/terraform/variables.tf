variable "region" { type=string default="us-east-1" }
variable "project" { type=string default="bank-deposits-mart-final" }
variable "vpc_cidr" { type=string default="10.42.0.0/16" }
variable "private_subnets" { type=list(string) default=["10.42.1.0/24","10.42.2.0/24"] }
variable "public_subnets"  { type=list(string) default=["10.42.11.0/24","10.42.12.0/24"] }
variable "redshift_username" { type=string }
variable "redshift_password" { type=string sensitive=true }
