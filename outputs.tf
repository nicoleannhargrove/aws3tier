output "talb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.talb.dns_name
}

