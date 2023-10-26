variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "student"
}

variable "hash_key" {
  description = "Name of the hash key attribute"
  type        = string
  default     = "student_id"
}

variable "range_key" {
  description = "Name of the range key attribute"
  type        = string
  default     = "timestamp"
}

variable "read_capacity" {
  description = "Read capacity units"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units"
  type        = number
  default     = 5
}
