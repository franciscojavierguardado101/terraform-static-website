# IAM user for deploying website files to S3 — least privilege, only what's needed
resource "aws_iam_user" "deployer" {
  name = "${var.environment}-website-deployer"

  tags = {
    Environment = var.environment
    Purpose     = "website-deployment"
  }
}

# Policy that only allows uploading, reading, deleting, and listing website files
resource "aws_iam_policy" "deployer" {
  name        = "${var.environment}-website-deployer-policy"
  description = "Least privilege policy for deploying static website files to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "deployer" {
  user       = aws_iam_user.deployer.name
  policy_arn = aws_iam_policy.deployer.arn
}
