variable "enable_redshift_snapshot_copy" {
  type        = bool
  default     = false
  description = "Enable cross-region snapshot copy for Redshift."
}

variable "dr_region" {
  type        = string
  default     = null
  description = "DR region for Redshift snapshot copies."
}

variable "dr_kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN in DR region for encrypted snapshot copies."
}

resource "aws_redshift_snapshot_copy" "this" {
  count               = var.enable_redshift_snapshot_copy && var.dr_region != null ? 1 : 0
  cluster_identifier  = aws_redshift_cluster.this.cluster_identifier
  destination_region  = var.dr_region
  grant_name          = null
  retention_period    = 7
  snapshot_copy_manual = true
  kms_key_id          = var.dr_kms_key_arn
}

