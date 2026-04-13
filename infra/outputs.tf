output "api_url" {
  description = "url of the api"
  # will put this into the README automatically later
  value = aws_apigatewayv2_api.api.api_endpoint
}