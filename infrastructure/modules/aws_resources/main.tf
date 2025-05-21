resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_data" {
  bucket = "${var.app_name}-${var.env_suffix}-data-${random_id.suffix.hex}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.app_name}-${var.env_suffix}-vpc"
  }
}