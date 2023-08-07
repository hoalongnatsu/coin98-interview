// S3 for file storage
resource "aws_s3_bucket" "file_storage" {
  bucket        = var.s3_file_storage
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_ownership_controls" "file_storage" {
  bucket = aws_s3_bucket.file_storage.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "file_storage" {
  bucket = aws_s3_bucket.file_storage.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.file_storage]
}

resource "aws_s3_bucket_versioning" "file_storage" {
  bucket = aws_s3_bucket.file_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

// S3 for codepipeline artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket        = var.s3_codepipeline_artifacts
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_ownership_controls" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_artifacts]
}
