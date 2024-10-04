# Use a specific AWS profile
provider "aws" {
  region  = "us-east-1"
  profile = "LabUserAccess-338065306366"
}

# Create an DynamoDB table
resource "aws_dynamodb_table" "iot_data" {
  name = "iot_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "sensor_id"

  attribute {
    name = "sensor_id"
    type = "S"
  }

}

# Create a dynamodb item
resource "aws_dynamodb_table_item" "iot_data_item" {
  table_name   = aws_dynamodb_table.iot_data.name
  hash_key = aws_dynamodb_table.iot_data.hash_key

  item = <<ITEM
  {
    "sensor_id"     : { "S" : "S01" },
    "sensor_model"  : { "S" : "tplink" },
    "location"      : { "S" : "living_room" },
    "temp"   : { "N" : "29" }
  }
  ITEM

}

