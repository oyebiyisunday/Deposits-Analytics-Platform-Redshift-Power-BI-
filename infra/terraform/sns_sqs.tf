resource "aws_sns_topic" "alerts" { name = "${var.project}-alerts" }
resource "aws_sqs_queue" "dlq" { name = "${var.project}-dlq" }
