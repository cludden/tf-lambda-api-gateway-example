# define api
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-lambda-api-${var.env}-${var.region}"
  description = "Example API using AWS Lambda"
}

# define production deployment
resource "aws_api_gateway_deployment" "default" {
  depends_on = [
    aws_api_gateway_method.hello_world,
    aws_api_gateway_integration.hello_world,
  ]

  stage_name  = "example_lambda_${var.env}"
  rest_api_id = aws_api_gateway_rest_api.example.id
}
