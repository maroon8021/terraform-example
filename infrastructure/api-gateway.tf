resource "aws_api_gateway_rest_api" "terraform_example_next_ssr_api" {
  name = "${var.prefix}_next_ssr_api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "terraform_example_next_ssr_api_root" {
  rest_api_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  resource_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "aws_api_gateway_resource_paths" {
  rest_api_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  resource_id   = aws_api_gateway_resource.terraform_example_resource_paths.id
  http_method   = "ANY"
  authorization = "NONE"
}

# resource "aws_api_gateway_method_settings" "terraform_example_next_ssr_api_logs" {
#   rest_api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
#   stage_name  = aws_api_gateway_stage.terraform_example_next_ssr_api.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled = true
#     logging_level   = "INFO"
#   }
# }

// `/` にきてもlambdaとつながるようにする
resource "aws_api_gateway_integration" "terraform_example_next_ssr_api_root" {
  rest_api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  resource_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.root_resource_id
  http_method = aws_api_gateway_method.terraform_example_next_ssr_api_root.http_method
  type        = "AWS_PROXY"

  uri                     = aws_lambda_function.terraform_example_next_ssr_function.invoke_arn
  integration_http_method = "POST" // ここはANYではなくPOSTを指定する必要がある

}

// `/*` などpath指定があるときにlambdaにそのまま流す用
resource "aws_api_gateway_integration" "terraform_example_next_ssr_api_paths" {
  rest_api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  resource_id = aws_api_gateway_resource.terraform_example_resource_paths.id
  http_method = aws_api_gateway_method.aws_api_gateway_resource_paths.http_method
  type        = "AWS_PROXY"

  uri                     = aws_lambda_function.terraform_example_next_ssr_function.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "terraform_example_next_ssr_api" {
  rest_api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id

  triggers = {
    redeployment = filebase64("${path.module}/api-gateway.tf")
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.terraform_example_next_ssr_api_root,
    aws_api_gateway_integration.terraform_example_next_ssr_api_paths
  ]
}



resource "aws_api_gateway_resource" "terraform_example_resource_paths" {
  rest_api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  parent_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_stage" "terraform_example_next_ssr_api" {
  deployment_id = aws_api_gateway_deployment.terraform_example_next_ssr_api.id
  rest_api_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
  stage_name    = "prod"
}





// --- for execute Lambda ---
resource "aws_lambda_permission" "terraform_example_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_example_next_ssr_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.terraform_example_next_ssr_api.execution_arn}/*/*/*"
}


// --- ApiKey ---
# resource "aws_ssm_parameter" "terraform_example_apikey_value" {
#   name  = "terraform_example_apikey_value"
#   type  = "String"
# }

resource "aws_api_gateway_api_key" "terraform_example_apikey" {
  name = "terraform_example_apikey"
  //value = aws_ssm_parameter.terraform_example_apikey_value.value
}

resource "aws_api_gateway_usage_plan" "terraform_example_usage_plan" {
  name = "terraform_example_usage_plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
    stage  = aws_api_gateway_stage.terraform_example_next_ssr_api.stage_name
  }

  depends_on = [
    aws_api_gateway_stage.terraform_example_next_ssr_api
  ]
}

resource "aws_api_gateway_usage_plan_key" "terraform_example_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.terraform_example_apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.terraform_example_usage_plan.id
}
