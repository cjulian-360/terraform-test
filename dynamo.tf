variable "spreadsheet_read_capacity" {
  description = "The number of read units for this table."
  default = 10
}

variable "spreadsheet_write_capacity" {
  description = "The number of write units for this table."
  default = 10
}

resource "aws_dynamodb_table" "spreadsheet" {
  name           = "orca-test-spreadsheet"
  read_capacity  = "${var.spreadsheet_read_capacity}"
  write_capacity = "${var.spreadsheet_write_capacity}"
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "expirationDate"
    type = "S"
  }

  global_secondary_index {
    name               = "expirationDate"
    hash_key           = "expirationDate"
    write_capacity     = "${var.spreadsheet_read_capacity}"
    read_capacity      = "${var.spreadsheet_read_capacity}"
    projection_type    = "ALL"
  }

  ttl {
    attribute_name = "expirationEpochDate"
    enabled = true
  }

  tags {
    Name = "orca-test-spreadsheet"
  }
}

data "aws_iam_policy_document" "spreadsheet" {
  statement {
    sid = "1"
    effect = "Allow",
    actions = [
      "dynamodb:*"
    ],

    resources = [
      "${aws_dynamodb_table.spreadsheet.arn}",
      "${aws_dynamodb_table.spreadsheet.arn}/index/*"
    ]
  }
}

resource "aws_iam_role_policy" "spreadsheet" {
  name = "orca-test-role-dynamodb-spreadsheet-policy"
  role = "orca-test-role"
  policy = "${data.aws_iam_policy_document.spreadsheet.json}"
}
