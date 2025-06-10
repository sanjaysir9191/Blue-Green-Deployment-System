output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "blue_target_group_arn" {
  description = "ARN of blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of green target group"
  value       = aws_lb_target_group.green.arn
}

output "ecr_repository_url" {
  description = "URL of ECR repository"
  value       = aws_ecr_repository.app.repository_url
}