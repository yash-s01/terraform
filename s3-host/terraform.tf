##### Creating an S3 Bucket #####

resource "aws_s3_bucket" "web-1234" {
  bucket = "tf-web-1234-buck"
  force_destroy = true
  tags = {
   "Owner" = "root"
  }
}

############# make a policy document ################

resource "aws_s3_bucket_policy" "name" {
  bucket = aws_s3_bucket.web-1234.id
  policy = data.aws_iam_policy_document.website_policy.json
}

########## feed policy details in the document ##############

data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:*"
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

###### add policy for public access #######

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.web-1234.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##### will upload all the files present under build_3 folder to the S3 bucket #####

# resource "aws_s3_object" "upload_object" {
#   for_each      = fileset("/Users/yashwant/Downloads/build_3", "**/*")
#   bucket        = aws_s3_bucket.web-1234.id
#   key           = each.value
#   source        = "/Users/yashwant/Downloads/build_3/${each.value}"
#   #etag         = filemd5("/Users/yashwant/Downloads/build_3/${each.key}")
#   #content_type  = "text/html"
# }

######### using module to upload folder for every content type ################

module "test_aws_s3_folder_1" {
  source = "github.com/chandan-singh/terraform-aws-s3-object-folder.git"

  bucket                = aws_s3_bucket.web-1234.id
  base_folder_path      = "/Users/yashwant/Downloads/build_3" # Or, something like "~/abc/xyz/build"
  file_glob_pattern     = "**"
  set_auto_content_type = true
}

#### for obtaining the endpoint####

output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}


