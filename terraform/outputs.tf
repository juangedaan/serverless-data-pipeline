
output "kinesis_stream_name" {
  value = aws_kinesis_stream.stream.name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.table.name
}
