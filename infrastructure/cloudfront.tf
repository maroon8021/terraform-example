// --- s3 ---
resource "aws_s3_bucket" "terraform_example_bucket" {
  bucket = "terraform-example-next-ssr"
}

resource "aws_s3_bucket_policy" "terraform_example_bucket_policy" {
  bucket = aws_s3_bucket.terraform_example_bucket.id
  policy = data.aws_iam_policy_document.terraform_example_bucket_policy_document.json
}

data "aws_iam_policy_document" "terraform_example_bucket_policy_document" {
  # CloudFront Distribution からのアクセスのみ許可
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.terraform_example_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.terraform_example_distribution.arn]
    }
  }
}



// --- cloudfront ---
resource "aws_cloudfront_distribution" "terraform_example_distribution" {

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_200"


  // api-gateway
  origin {
    origin_id   = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
    domain_name = "${aws_api_gateway_rest_api.terraform_example_next_ssr_api.id}.execute-api.ap-northeast-1.amazonaws.com"
    origin_path = "/${aws_api_gateway_stage.terraform_example_next_ssr_api.stage_name}"

    custom_header {
      name  = "x-api-key"
      value = aws_api_gateway_api_key.terraform_example_apikey.value
    }

    custom_origin_config {
      http_port  = 80
      https_port = 443

      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]

      // this below is default
      # connection_attempts = 3
      # connection_timeout  = 10

      // this below is default
      # origin_read_timeout      = 60
      # origin_keepalive_timeout = 60
    }
  }

  // static assets on s3
  origin {
    origin_id                = aws_s3_bucket.terraform_example_bucket.id
    domain_name              = aws_s3_bucket.terraform_example_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.terraform_example_access_s3.id

  }


  default_cache_behavior {
    target_origin_id       = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
    viewer_protocol_policy = "allow-all"

    compress = false

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]

    # forwarded_values {
    #   headers = [
    #     "Accept",
    #     "Accept-Encoding",
    #     "Accept-Language",
    #     "Origin",
    #   ]
    #   query_string            = true
    #   query_string_cache_keys = []
    #   cookies {
    #     forward = "all"
    #   }
    # }


    cache_policy_id = aws_cloudfront_cache_policy.terraform_example_cache_policy_for_apikey.id
  }



  // next/linkでクライアントサイドでルーティングする際にjsonを取得できるようにする
  ordered_cache_behavior {
    target_origin_id       = aws_api_gateway_rest_api.terraform_example_next_ssr_api.id
    viewer_protocol_policy = "allow-all"
    path_pattern           = "/_next/data/*"

    compress = false

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {
      headers = [
        "Accept",
        "Accept-Encoding",
        "Accept-Language",
        "Origin",
      ]
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward = "all"
      }
    }

    # Using the CachingDisabled managed policy ID:
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-policy-caching-disabled
    // cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39a"
    min_ttl = 0
  }

  ordered_cache_behavior {
    target_origin_id       = aws_s3_bucket.terraform_example_bucket.id
    viewer_protocol_policy = "allow-all"
    path_pattern           = "/_next/*"

    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]

    // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-caching-optimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  // ないと怒られた
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  // ないと怒られた
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


resource "aws_cloudfront_cache_policy" "terraform_example_cache_policy_for_apikey" {
  name = "terraform_example_cache_policy_for_apikey"
  // 全部のttlを0にしたらcacheのdisabled扱いになって怒られた
  min_ttl = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["x-api-key"]
      }
    }
    // ないと怒られた
    cookies_config {
      cookie_behavior = "all"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "terraform_example_access_s3" {
  name                              = "access-s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
