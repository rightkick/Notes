# Create a user
resource "aws_iam_user" "test-user" {
    name = "test-user"
    tags = {
        Description = "This is a test user"
    }
}

# Create a policy
resource "aws_iam_policy" "S3-bucket-read" {
    name = "S3-bucket-read"
    policy = file("s3-bucket-read-policy.json")
}

# Attach the policy to the user
resource "aws_iam_user_policy_attachment" "test-user-s3-access" {
    user = aws_iam_user.test-user.name
    policy_arn = aws_iam_policy.S3-bucket-read.arn
}

# Create an EC2 instance

# Create an S3 bucket

# Create a role for EC2->S3

# Attach role to EC2