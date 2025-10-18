locals {
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Redshift", "QueryDuration", "ClusterIdentifier", "${var.project}-ra3"],
            ["AWS/Redshift", "WLMQueueLength", "ClusterIdentifier", "${var.project}-ra3"],
            ["AWS/Redshift", "CPUUtilization", "ClusterIdentifier", "${var.project}-ra3"],
          ]
          view   = "timeSeries"
          stacked = false
          region = var.region
          title  = "Redshift Performance Metrics"
          period = 300
          stat   = "Average"
          yAxis  = { left = { min = 0 } }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Redshift", "DatabaseConnections", "ClusterIdentifier", "${var.project}-ra3"],
            ["AWS/Redshift", "NetworkReceiveThroughput", "ClusterIdentifier", "${var.project}-ra3"],
            ["AWS/Redshift", "NetworkTransmitThroughput", "ClusterIdentifier", "${var.project}-ra3"],
          ]
          view   = "timeSeries"
          stacked = false
          region = var.region
          title  = "Redshift Network & Connections"
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["${var.project}/SLA", "DataArrivalDelay", "Dataset", "sqlserver/transactions"],
            ["${var.project}/SLA", "ProcessingDuration", "JobName", "J_ORCH_Load_Deposits"],
            ["${var.project}/SLA", "DataFreshnessAge", "Schema", "mart"],
          ]
          view   = "timeSeries"
          stacked = false
          region = var.region
          title  = "SLA Metrics"
          period = 300
          stat   = "Maximum"
          annotations = {
            horizontal = [
              { label = "Data Arrival SLA (30 min)", value = 30 },
              { label = "Processing SLA (60 min)", value = 60 },
              { label = "Freshness SLA (120 min)", value = 120 },
            ]
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "etl_health" {
  dashboard_name = "${var.project}-ETL-Pipeline-Health"
  dashboard_body = local.dashboard_body
}

