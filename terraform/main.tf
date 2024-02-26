provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "html-to-json-input" {
  bucket = "${var.bucket_name}-${var.environment}-input1"

  tags = {
    Name        = "${var.bucket_name}-${var.environment}-input1"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "html-to-json-output" {
  bucket = "${var.bucket_name}-${var.environment}-output1"

  tags = {
    Name        = "${var.bucket_name}-${var.environment}-output1"
    Environment = var.environment
  }
}

resource "aws_iam_role" "html-to-json-lambda-role" {
  name = "html-to-json-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "html-to-json-lambda-policy" {
  name = "html-to-json-lambda-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
      }, {
      Effect = "Allow"
      Action = [
        "s3:*",
        "s3-object-lambda:*"
      ]
      Resource = ["*"]
    }]
  })
}

output "s3_bucketname" {
  value = aws_s3_bucket.html-to-json-input.id
}


resource "aws_iam_role_policy_attachment" "html-to-json-lambda-role-policy-attachment" {
  policy_arn = aws_iam_policy.html-to-json-lambda-policy.arn
  role       = aws_iam_role.html-to-json-lambda-role.name
}

resource "aws_lambda_function" "html-to-json-lambda" {
  function_name    = "html-to-json-lambda"
  filename         = "../lambda_function_payload.zip"
  source_code_hash = filebase64sha256("../lambda_function_payload.zip")
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.html-to-json-lambda-role.arn
  runtime          = "python3.11"
}

resource "aws_sns_topic" "html-to-json-sns" {
  name = "html-to-json-sns"
}

resource "aws_sns_topic_subscription" "example" {
  topic_arn = aws_sns_topic.html-to-json-sns.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.html-to-json-lambda.arn
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.html-to-json-lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.html-to-json-sns.arn
}

resource "aws_sqs_queue" "sh_queue" {
  name                       = "sh-example-queue"
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

# Allow the S3 bucket to write to the SQS queue
resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.sh_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.sh_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_s3_bucket.html-to-json-input.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.html-to-json-input.id
  queue {
    queue_arn = aws_sqs_queue.sh_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# Display the S3 bucket and the SQS queue URL
output "S3-Bucket" {
  value       = aws_s3_bucket.html-to-json-output.id
  description = "The S3 Bucket"
}