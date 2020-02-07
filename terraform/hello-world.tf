# lambda function
# =================================================================================

# create lambda function archive
data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "../dist/hello-world.js"
  output_path = "../dist/hello-world.zip"
}

data "template_file" "hello_world" {
  template = "hello-world-${var.env}-${var.region}"
}

# create hello-world lambda function
resource "aws_lambda_function" "hello_world" {
  function_name = data.template_file.hello_world.rendered
  filename      = data.archive_file.hello_world.output_path
  runtime       = "nodejs10.x"
  role          = aws_iam_role.hello_world.arn
  handler       = "hello-world.handler"
  timeout       = 10

  environment {
    variables = {
      "NODE_ENV" = "production"
    }
  }
}

# IAM
# =================================================================================

# define lambda function role
resource "aws_iam_role" "hello_world" {
  name               = data.template_file.hello_world.rendered
  assume_role_policy = data.aws_iam_policy_document.hello_world_assume_role.json
}

# define assume role policy for above role
data "aws_iam_policy_document" "hello_world_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
    }
  }
}

# define iam policy with logging permissions
resource "aws_iam_policy" "hello_world" {
  name        = aws_lambda_function.hello_world.function_name
  description = "basic cloudwatch logging permissions"

  policy = data.aws_iam_policy_document.hello_world.json
}

# policy definition for above policy
data "aws_iam_policy_document" "hello_world" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

# attach above policy to above role
resource "aws_iam_policy_attachment" "hello_world" {
  name       = aws_lambda_function.hello_world.function_name
  roles      = [aws_iam_role.hello_world.id]
  policy_arn = aws_iam_policy.hello_world.arn
}

# cloudwatch
# =================================================================================

# include cloudwatch log group resource definition in order to ensure it is
# removed with function removal
resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
}

# api gateway
# =================================================================================

# allow api gateway to invoke reindexer_dispatch function
resource "aws_lambda_permission" "hello_world" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.hello_world.http_method}${aws_api_gateway_resource.hello_world.path}"
}

# route path for hello world "/hello"
resource "aws_api_gateway_resource" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "hello"
}

# route method for generating a greeting with an optional name "POST /hello"
resource "aws_api_gateway_method" "hello_world" {
  rest_api_id      = aws_api_gateway_rest_api.example.id
  resource_id      = aws_api_gateway_resource.hello_world.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

# route reponse for "POST /reindex"
resource "aws_api_gateway_method_response" "hello_world_success" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.hello_world.id
  http_method = aws_api_gateway_method.hello_world.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# connect route above with our hello-world lambda function
resource "aws_api_gateway_integration" "hello_world" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.hello_world.id
  http_method             = aws_api_gateway_method.hello_world.http_method
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_world.arn}/invocations"
  integration_http_method = "POST"
}

# connect response from lambda to route response
resource "aws_api_gateway_integration_response" "hello_world" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.hello_world.id
  http_method = aws_api_gateway_method.hello_world.http_method
  status_code = aws_api_gateway_method_response.hello_world_success.status_code
  depends_on  = [aws_api_gateway_integration.hello_world]

  response_templates = {
    "application/json" = ""
  }
}
