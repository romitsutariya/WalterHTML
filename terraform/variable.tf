variable "environment" {
  sensitive = false
  type      = string
  default   = "development"
}

variable "bucket_name" {
  type    = string
  default = "walter-json-to-html"
}