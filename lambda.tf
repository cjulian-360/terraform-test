resource "aws_lambda_function" "orca_ttl_handler_lambda" {
  description = "handles Orca dynamodb TTL stream events, sending expired record id's to an Orca endpoint"
  filename = "./orcaTTLHandler.zip"
  function_name = "orca_test_ttl_handler_lambda"
  handler = "orcaTTLHandler.orcaTTLHandler"
  role = "arn:aws:iam::325598114173:role/service-role/stream-event-handler"
  runtime = "nodejs8.10"
  source_code_hash = "${base64sha256(file("./orcaTTLHandler.zip"))}"
  timeout = "5"
  vpc_config = {
    subnet_ids = ["subnet-de8ec4e4", "subnet-2ca2c120", "subnet-b5d453ec", "subnet-2f65c904", "subnet-03f88a66", "subnet-f77a1c80"]
    security_group_ids = ["sg-0081545534184bc83"]
  }

  environment {
    variables = {
      ORCA_HOST = "internal-orca-load-balancer-58401402.us-east-1.elb.amazonaws.com"
    }
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size = 100
  event_source_arn = "${aws_dynamodb_table.spreadsheet.stream_arn}"
  enabled = true
  function_name = "${aws_lambda_function.orca_ttl_handler_lambda.arn}"
  starting_position = "TRIM_HORIZON"
}