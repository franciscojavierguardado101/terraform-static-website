# S3 bucket for website files
module "s3_website" {
  source      = "../../modules/s3-website"
  bucket_name = "francisco-guardado-${var.environment}-website"
  environment = var.environment
}

# CloudFront CDN — serves the website globally and handles HTTPS
module "cloudfront" {
  source                         = "../../modules/cloudfront"
  environment                    = var.environment
  s3_bucket_id                   = module.s3_website.bucket_id
  s3_bucket_regional_domain_name = module.s3_website.bucket_regional_domain_name
  price_class                    = "PriceClass_All"  # prod uses all global edge locations
}

# Bucket policy connecting S3 to CloudFront — kept here to avoid circular dependency between modules
resource "aws_s3_bucket_policy" "website" {
  bucket = module.s3_website.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_website.bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = module.cloudfront.distribution_arn
          }
        }
      }
    ]
  })
}

# IAM deployer user with least privilege access to the website bucket
module "iam" {
  source        = "../../modules/iam"
  environment   = var.environment
  s3_bucket_arn = module.s3_website.bucket_arn
}

# GCS bucket on Google Cloud — backup mirror of the website
module "gcs_backup" {
  source        = "../../modules/gcs-backup"
  bucket_name   = "francisco-guardado-${var.environment}-website-backup"
  location      = "US"
  environment   = var.environment
  force_destroy = false  # never auto-delete prod data
}
