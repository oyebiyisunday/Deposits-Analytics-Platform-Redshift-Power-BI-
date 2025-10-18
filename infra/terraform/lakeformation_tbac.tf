variable "enable_lf_tbac" {
  type        = bool
  default     = false
  description = "Enable Lake Formation tag-based access control (TBAC) on curated DB/tables."
}

resource "aws_lakeformation_lf_tag" "domain" {
  count          = var.enable_lf_tbac ? 1 : 0
  key            = "domain"
  values         = ["deposits"]
}

resource "aws_lakeformation_lf_tag" "sensitivity" {
  count  = var.enable_lf_tbac ? 1 : 0
  key    = "sensitivity"
  values = ["pii", "non-pii"]
}

resource "aws_lakeformation_lf_tag_assignment" "db_tags" {
  count = var.enable_lf_tbac ? 1 : 0
  lf_tag {
    key   = aws_lakeformation_lf_tag.domain[0].key
    value = "deposits"
  }
  lf_tag {
    key   = aws_lakeformation_lf_tag.sensitivity[0].key
    value = "non-pii"
  }
  resource {
    database {
      name = aws_glue_catalog_database.curated.name
    }
  }
}

resource "aws_lakeformation_permissions" "tbac_example" {
  count      = var.enable_lf_tbac ? 1 : 0
  principal  = aws_iam_role.glue_crawler.arn
  permissions = ["ALL"]
  lf_tag_policy {
    resource_type = "TABLE"
    expression {
      key    = aws_lakeformation_lf_tag.domain[0].key
      values = ["deposits"]
    }
    expression {
      key    = aws_lakeformation_lf_tag.sensitivity[0].key
      values = ["non-pii"]
    }
  }
}

