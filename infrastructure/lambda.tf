resource "aws_ecr_repository" "terraform_example_next_ssr_repo" {
  name                 = "terraform_example_next_ssr_repo"
  image_tag_mutability = "IMMUTABLE"
}


resource "aws_lambda_function" "terraform_example_next_ssr_function" {
  function_name = "terraformExampleNextSSR"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.terraform_example_next_ssr_repo.repository_url}:latest"
  role          = aws_iam_role.terraform_example_lambda_iam.arn
  timeout       = 30

  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }

  depends_on = [
    aws_ecr_repository.terraform_example_next_ssr_repo
  ]

}
