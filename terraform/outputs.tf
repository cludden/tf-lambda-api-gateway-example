output "url" {
  value = "https://${aws_api_gateway_deployment.default.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.default.stage_name}"
}
