variable "enable_redshift_schedules" {
  type        = bool
  default     = false
  description = "Enable scheduled resize actions for Redshift cluster."
}

variable "offpeak_nodes" { type = number, default = 1 }
variable "offpeak_cron"  { type = string,  default = "cron(0 2 * * ? *)" }
variable "peak_nodes"    { type = number, default = 2 }
variable "peak_cron"     { type = string,  default = "cron(0 12 * * ? *)" }

resource "aws_redshift_scheduled_action" "scale_offpeak" {
  count      = var.enable_redshift_schedules ? 1 : 0
  name       = "${var.project}-scale-offpeak"
  schedule   = var.offpeak_cron
  iam_role   = aws_iam_role.redshift.arn
  target_action {
    resize_cluster {
      cluster_identifier = aws_redshift_cluster.this.cluster_identifier
      number_of_nodes    = var.offpeak_nodes
    }
  }
}

resource "aws_redshift_scheduled_action" "scale_peak" {
  count      = var.enable_redshift_schedules ? 1 : 0
  name       = "${var.project}-scale-peak"
  schedule   = var.peak_cron
  iam_role   = aws_iam_role.redshift.arn
  target_action {
    resize_cluster {
      cluster_identifier = aws_redshift_cluster.this.cluster_identifier
      number_of_nodes    = var.peak_nodes
    }
  }
}

