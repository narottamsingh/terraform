resource "aws_dynamodb_table_item" "item1" {
    depends_on = [
        aws_dynamodb_table.demo_dynamodb_table
    ]

    table_name      = aws_dynamodb_table.demo_dynamodb_table.name
    hash_key        = aws_dynamodb_table.demo_dynamodb_table.hash_key
    
     item = <<ITEM
        {
        "student_id": {"S": "101"},
        "timestamp": {"S": "2023-10-26"}
        }
        ITEM        
}

