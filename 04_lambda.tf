resource "aws_iam_policy" "lambda_at_edge" {
  name        = "LambdaAtEdgeExecutionRolePolicy"
  description = "Execution role policy for Lambda"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action: "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_at_edge_exec_role" {
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "sts:AssumeRole"
          Principal = {
            Service = [
              "lambda.amazonaws.com",
              "edgelambda.amazonaws.com",
            ]
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_at_edge_attach" {
  policy_arn = aws_iam_policy.lambda_at_edge.arn
  role       = aws_iam_role.lambda_at_edge_exec_role.name
}


resource "aws_lambda_function" "fixed_http_basic_auth" {
  provider      = aws.useast1
  function_name = "http_basic_auth_lambda"
  description   = "Authenticates a request with HTTP Basic authentication"
  role          = aws_iam_role.lambda_at_edge_exec_role.arn
  handler       = "authoriser.handler"
  runtime       = "python3.7"
  publish       = true
  layers        = []
  architectures = [
    "x86_64",
  ]

  filename         = "${path.module}/lambda-src/authoriser.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-src/authoriser.zip")

  tags = {
    "lambda:createdBy" = "SAM"
  }
}
