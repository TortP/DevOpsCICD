output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_url" {
  description = "S3 bucket URL"
  value       = format("s3://%s", aws_s3_bucket.terraform_state.id)
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}
