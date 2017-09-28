variable "env" {
  type        = "string"
  description = "environment name"
}

variable "region" {
  type        = "string"
  description = "aws region"
  default     = "us-west-2"
}
