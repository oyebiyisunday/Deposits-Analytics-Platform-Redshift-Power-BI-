terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws     = { source = "hashicorp/aws",     version = "~> 5.0" }
    archive = { source = "hashicorp/archive", version = "~> 2.4" }
  }
  backend "s3" {}
}
provider "aws" { region = var.region }
 
# Default tags for cost and ownership
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project            = var.project
      Environment        = var.environment
      Owner              = coalesce(var.owner, "unknown")
      CostCenter         = coalesce(var.cost_center, "unspecified")
      DataClassification = var.data_classification
    }
  }
}
