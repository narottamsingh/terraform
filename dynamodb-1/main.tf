resource "aws_dynamodb_table" "demo_dynamodb_table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  hash_key       = var.hash_key
  #range_key      = var.range_key
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  attribute {
    name = var.hash_key
    type = "S"
  }


  ttl {
    attribute_name = "ttl"
    enabled        = false
  }
}
