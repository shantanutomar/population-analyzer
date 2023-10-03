variable "aws-access-key" {
  type = string
  description = "Access key for AWS account"
}

variable "aws-secret-key" {
  type = string
  description = "Secret key for AWS account"
}

variable "aws-region" {
  type = string
  description = "Region to deploy to"
}

variable "postgres_password" {
  type = string
  description = "postgres password"
}

variable "postgres_database" {
  type = string
  description = "postgres password"
}
