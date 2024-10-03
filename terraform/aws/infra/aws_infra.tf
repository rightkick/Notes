# Use a specific AWS profile
provider "aws" {
  region  = "us-east-1"
  profile = "LabUserAccess-338065306366"
}

# Create an S3 bucket
resource "aws_s3_bucket" "test_bucket" {
    bucket = "alexk-test-bucket-03102024"
    tags = {
        Description = "My test bucket for tf testing"
    }
}

# Upload a file to S3
resource "aws_s3_object" "s3-test-file" {
  bucket = aws_s3_bucket.test_bucket.id
  key = "s3-data-test-file"
  source = "s3-data.txt"
}

# Create an EC2 instance

