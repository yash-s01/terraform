##### Creating an S3 Bucket #####

resource "aws_s3_bucket" "web-1234" {
  bucket = "tf-web-1234-buck"
  force_destroy = true
  tags = {
   "Owner" = "root"
  }
}

resource "aws_s3_bucket_policy" "name" {
  bucket = aws_s3_bucket.web-1234.id
  policy = data.aws_iam_policy_document.website_policy.json
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "${aws_s3_bucket.web-1234.arn}/*"
    ]
  }
}

###### configure website pages#######

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.web-1234.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# #####update bucket policy for get object###########

# resource "aws_s3_bucket_policy" "web-1234" {
#   bucket = aws_s3_bucket.web-1234.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject",
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "s3:GetObject",
#         Resource  = "${aws_s3_bucket.web-1234.arn}/*"
#       }
#     ]
#   })
# }

###### add policy for public access #######

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.web-1234.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

  ##### will upload all the files present under build_3 folder to the S3 bucket #####

resource "aws_s3_object" "upload_object" {
  for_each      = fileset("/Users/yashwant/Downloads/build_3", "**/*")
  bucket        = aws_s3_bucket.web-1234.id
  key           = each.value
  source        = "/Users/yashwant/Downloads/build_3/${each.value}"
  content_type = "text/html"
}

#### for obtaining the endpoint####

output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}


