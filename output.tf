output "elb_url" {
  value = aws_elb.web.dns_name
}

output "rds_address" {
  value = aws_db_instance.privateRDS.address
}
