output "api_url" {
    
    description = "url of the API"
    value = aws_apigatewayv2_api.api.api_endpoint
  
}