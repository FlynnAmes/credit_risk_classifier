resource "aws_apigatewayv2_api" "api" {
  name = var.api_gateway_name
  # simpler for now
  protocol_type = "HTTP"

}

# set up integration with lambda
resource "aws_apigatewayv2_integration" "integration" {
  # assign api
  api_id = aws_apigatewayv2_api.api.id
  # so can communicate with lambda
  integration_type = "AWS_PROXY"
  # get uri of the lambda function
  integration_uri = var.lambda_arn
}

# create stage and set to default for now
resource "aws_apigatewayv2_stage" "stage" {

  api_id = aws_apigatewayv2_api.api.id
  # for now keep singular stage for API, with different APIs for different envs (to decouple app from the infrastructure)
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit = var.rate_limit
  }

}

######
# now define the routes
######

# predict
resource "aws_apigatewayv2_route" "predict" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /predict"

  # route needs to target the integration
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

# health
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /health"

  # route needs to target the integration
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

# ready
resource "aws_apigatewayv2_route" "ready" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /ready"

  # route needs to target the integration
  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

# need to give APIgateway permission to invoke the lambda function
resource "aws_lambda_permission" "lambda_permission" {

  # lambda function
  function_name = var.lambda_function_name
  # let invoke
  action = "lambda:InvokeFunction"
  # let APIgateway do it
  principal = "apigateway.amazonaws.com"
}
