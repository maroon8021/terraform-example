resource "aws_iam_role" "terraform_example_lambda_iam" {
  name = "${var.prefix}_lambda_iam"

  assume_role_policy = data.aws_iam_policy_document.terraform_example_execure_lambda_document.json
}


data "aws_iam_policy_document" "terraform_example_execure_lambda_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "terraform_example_write_cloudwatch_log_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "terraform_example_write_cloudwatch_log" {
  name = "${var.prefix}write-cloudwatch-logs-policy"
  path = "/"

  policy = data.aws_iam_policy_document.terraform_example_write_cloudwatch_log_document.json
}

resource "aws_iam_role_policy_attachment" "terraform_example_attach_write_cloudwatch_logs" {
  role       = aws_iam_role.terraform_example_lambda_iam.name
  policy_arn = aws_iam_policy.terraform_example_write_cloudwatch_log.arn
}


// --- for api-gateway ---


# resource "aws_api_gateway_rest_api_policy" "terraform_example_api_gateway_resource_policy" {
#   rest_api_id = aws_api_gateway_rest_api.sirius-frontend-api.id
#   policy      = data.aws_iam_policy_document.
# }

